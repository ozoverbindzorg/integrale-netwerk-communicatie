### The OZO platform from a functional perspective

The OZO platform connects care professionals with informal caregivers. The platform is able to create a link between the
formal healthcare network with the informal social environment of the patient. Hereby the OZO platform needs to cross
borders of healthcare and open up to the social context of the patents.

TODO: give a functional overview.

### FHIR Resources and Profiles

For a complete list of all FHIR profiles, examples, and resources defined in this Implementation Guide, see the [Artifacts](artifacts.html) page. The Artifacts page includes links to the FSH source files for all resources.

### The OZO care network datamodel

### About the name element.

Please refer to the following documentation of the Dutch name element:

* [NameInformation-v1.0(2017EN)](https://zibs.nl/wiki/NameInformation-v1.0(2017EN))

The FHIR API is based on FHIR R4 and makes use of the following FHIR resources:

#### Patient

**Profile:** [OZOPatient](StructureDefinition-ozo-patient.html)

The `Patient` represents the client in the domain, for each real-life patient only one single entity exists. The
`Patient`
is primary identified by the BSN. Required fields:

| field                           | cardinality | description         |
|---------------------------------|-------------|---------------------|
| identifier (OZO person)         | 1..1        | System: `https://www.ozoverbindzorg.nl/namingsystem/ozo/person` or `ozo-connect/person` |
| name                            | 1..*        | The name field, ZIB |
| gender                          | 1..1        |                     |
| birthDate                       | 1..1        |                     |
| active                          | 1..1        | true                |

##### Identity mapping

The identifier of the `Patient` _must_ be unique and _should_ the internal identifier of the patient in the OZO system.

##### Examples
* [H-de-Boer](Patient-H-de-Boer.html)

#### Related Person

**Profile:** [OZORelatedPerson](StructureDefinition-ozo-relatedperson.html)

The related person resource represents the relation between `Patient` and a informal caregiver (`RelatedPerson`). For
each _relationship_
between a patient and informal caregiver one related person exists. For each real-life person multiple related person
resources exist, one for each patient it has a caregiving relationship with.

| field                                                                    | cardinality | description                            |
|--------------------------------------------------------------------------|-------------|----------------------------------------|
| identifier (OZO person + network-relation)                               | 1..*        | Systems: `https://www.ozoverbindzorg.nl/namingsystem/ozo/person` and `/network-relation` |
| name                                                                     | 1..*        | The name field, ZIB                    |
| patient                                                                  | 1..1        | The reference to the patient           |
| relationship                                                             | 1..1        | system=urn:oid:2.16.840.1.113883.5.111 |
| active                                                                   | 1..1        | true                                   |

The relationship coding can be found here:

* [https://zibs.nl/wiki/Familieanamnese-v3.2(2021NL)](https://zibs.nl/wiki/Familieanamnese-v3.2(2021NL))

##### Identity mapping

The OZO FHIR `RelatedPerson` uses two identities to identify the RelatedPerson entity:

1. The internal account of the related person in the OZO system, this identifier is NOT unique for each relationship and
   identical for each OZO user account linked to a real-life person.
2. The relationship identifier in the OZO system, unique for each relationship between a the OZO related person account
   and the patient.

##### Examples
* [Kees-Groot](RelatedPerson-Kees-Groot.html)

#### Practitioner

**Profile:** [OZOPractitioner](StructureDefinition-ozo-practitioner.html)

The `Practitioner` represents a health care professional that has a relationship with one or more patients. The
practitioner is linked to the patient by the care team. `OZOPractitioner` extends the [NL Generic Functions Practitioner profile](https://build.fhir.org/ig/nuts-foundation/nl-generic-functions-ig/StructureDefinition-nl-gf-practitioner.html) (`nl-gf-practitioner`), providing compliance with the Dutch care services directory and IHE mCSD alignment.

| field                    | Cardinality | description                                                        |
|--------------------------|-------------|--------------------------------------------------------------------|
| identifier[AssignedId]   | 1..1        | Platform-assigned identifier with assigner (required by NL-GF)     |
| name                     | 1..*        | The name field, ZIB                                                |
| active                   | 1..1        | true                                                               |

For details on directory participation and identifier requirements, see the [Care Services Directory](care-services-directory.html) page.

#### Identity mapping

The identifier of the `Practitioner` _must_ be unique and _should_ be the internal identifier of the practitioner in the OZO
system.

##### Examples
* [Manu-van-Weel](Practitioner-Manu-van-Weel.html)
* [Mark-Benson](Practitioner-Mark-Benson.html)
* [A-P-Otheeker](Practitioner-A-P-Otheeker.html)

#### CareTeam (Patient)

**Profile:** [OZOCareTeam](StructureDefinition-ozo-careteam.html)

The `CareTeam` is the resource that binds the patient to the related person(s) and practitioners. There _should_ exist
only one care team resource for each patient in the system. Multiple care team resources _could_ exist if specific use
cases require this. A CareTeam has a set of `participants` that consists of a `member`. For practitioners, this
relationship _should_ also contain the `onBehalfOf` property, linking to the `Organization`, this maps the relation of
the `Patient` to different `Organization`s. Participants can also include organizational teams (see below) for nested team references.

| field       | Cardinality | description                                                                                       |
|-------------|-------------|---------------------------------------------------------------------------------------------------|
| subject     | 1..1        | reference to the `Patient`                                                                        |
| participant | 1..*        | a reference to a `Practitioner`, `RelatedPerson`, or `OZOOrganizationalCareTeam` (nested team)    |
| status      | 1..1        | "active"                                                                                          |

##### Examples
* [Netwerk-H-de-Boer](CareTeam-Netwerk-H-de-Boer.html)
* [Netwerk-Jan-de-Hoop](CareTeam-Netwerk-Jan-de-Hoop.html) (includes a nested organizational team)

#### CareTeam (Organizational)

**Profile:** [OZOOrganizationalCareTeam](StructureDefinition-ozo-organizational-careteam.html)

The `OZOOrganizationalCareTeam` represents a department or organizational unit (e.g., pharmacy team, clinic team) that is **not** bound to a specific patient. It is used for:
* **Team-to-team messaging** — as sender (via the `senderCareTeam` extension) and recipient in conversations between organizations
* **Shared inbox** — all team members can see and respond to messages addressed to the team
* **Nested teams** — can be included as a participant in a patient's `CareTeam`

| field                | Cardinality | description                                                          |
|----------------------|-------------|----------------------------------------------------------------------|
| subject              | 0..0        | not allowed — organizational teams have no patient                   |
| name                 | 1..1        | team display name                                                    |
| category             | 1..*        | SNOMED CT coded team type (e.g., pharmacy service, general medicine) |
| managingOrganization | 1..1        | reference to the `Organization` this team belongs to                 |
| participant          | 1..*        | a reference to a `Practitioner` (only practitioners, no RelatedPerson) |
| status               | 1..1        | "active"                                                             |

##### Examples
* [Pharmacy-A](CareTeam-Pharmacy-A.html) - Pharmacy team for team-level messaging
* [Clinic-B](CareTeam-Clinic-B.html) - Clinic team for team-level messaging
* [Department-Thuiszorg](CareTeam-Department-Thuiszorg.html) - Organizational department team

#### Organization

**Profile:** [OZOOrganization](StructureDefinition-ozo-organization.html)

The `Organization` resource represents the different organizations in the network. `OZOOrganization` extends the [NL Generic Functions Organization profile](https://build.fhir.org/ig/nuts-foundation/nl-generic-functions-ig/StructureDefinition-nl-gf-organization.html) (`nl-gf-organization`), providing compliance with the Dutch care services directory and IHE mCSD alignment. The relation between the Patient and Organization is managed by the participant in the care team. Each member of type Practitioner has an onBehalfOf reference to the Organization.

| field                    | Cardinality | description                                                        |
|--------------------------|-------------|--------------------------------------------------------------------|
| identifier[ura]          | 0..*        | URA identifier (required unless `partOf` is set)                   |
| identifier[AssignedId]   | 1..1        | Platform-assigned identifier with assigner (required by NL-GF)     |
| type                     | 1..*        | Organization type from Nictiz organization-type code system        |
| name                     | 1..1        | The name of the `Organization`                                     |

For details on directory participation and identifier requirements, see the [Care Services Directory](care-services-directory.html) page.

##### Examples

* [Ziekenhuis-Amsterdam](Organization-Ziekenhuis-Amsterdam.html)
* [Ziekenhuis-Amsterdam-2](Organization-Ziekenhuis-Amsterdam-2.html)
* [Huisarts-Amsterdam](Organization-Huisarts-Amsterdam.html)
* [Apotheek-de-Pil](Organization-Apotheek-de-Pil.html)

### Diagram
{::nomarkdown}
{% include fhir-network-datamodel.svg %}
{:/}

### Interaction with the OZO FHIR Api
The different interactions are described in the following guides:

* [Interaction - Creating the network](interaction-network.html)


### The OZO messaging datamodel

Messaging can be used within the OZO FHIR API. To achieve this, the following 2 FHIR Resources are used:

#### CommunicationRequest

**Profile:** [OZOCommunicationRequest](StructureDefinition-ozo-communicationrequest.html)

The `CommunicationRequest` Resource is used to:

* Initially request a thread
* Group messages into a thread
* Manage the status of a thread in a clear place
* Manage the participants of a thread in a clear place
* Display a list of threads for a Patient

##### Fields

| field     | Cardinality | description                                                          |
|-----------|-------------|----------------------------------------------------------------------|
| status    | 1..1        | draft  \| active \| completed                                        |
| subject   | 1..1        | Reference to a `Patient`                                             |
| requester | 1..1        | a reference to a `RelatedPerson` or `Practitioner` (individual who initiated - for auditability) |
| sender    | 0..1        | a reference to a `RelatedPerson` or `Practitioner` (individual sender)                                           |
| extension[senderCareTeam] | 0..1 | a reference to a `CareTeam` (reply-to address for team-level messaging)                        |
| recipient | 1..*        | a reference to a `RelatedPerson`, `Practitioner` or `CareTeam`       |
| payload   | 1..*        | Message or attachment, one of `contentString` or `contentAttachment` |

##### Team-Level Messaging

The `CommunicationRequest` supports team-level messaging through the `senderCareTeam` extension (FHIR R4 `CommunicationRequest.sender` does not allow CareTeam references):

* **`requester`**: Always an individual (`Practitioner` or `RelatedPerson`) - tracks who initiated the conversation for auditability
* **`sender`**: Always an individual (`Practitioner` or `RelatedPerson`) - the person who created the thread
* **`extension[senderCareTeam]`**: A `CareTeam` reference that enables team-level messaging:
  * Provides the **reply-to address** for the conversation thread
  * Grants **team-level authorization** for message management (archive, delete)
  * Enables the **shared inbox pattern** where all team members can see and respond to messages

When replying to a team-level thread, read the `CareTeam` from `CommunicationRequest.extension[senderCareTeam]` to determine the reply recipient.

##### Examples
* [Thread-Example](CommunicationRequest-Thread-Example.html) - Individual-to-CareTeam messaging
* [Pharmacy-to-Clinic](CommunicationRequest-Pharmacy-to-Clinic.html) - Team-to-team messaging

#### Communication

**Profile:** [OZOCommunication](StructureDefinition-ozo-communication.html)

The `Communication` resource is used to:

* Place a message in a thread.

##### Fields

| field        | Cardinality | description                                                                                               |
|--------------|-------------|-----------------------------------------------------------------------------------------------------------|
| status       | 1..1        | preparation \| in-progress  \| not-done \| on-hold \| stopped \| completed \| entered-in-error \| unknown |
| partOf       | 1..1        | Reference to a `CommunicationRequest`                                                                     |
| inResponseTo | 0..1        | Reference to a previous `Communication` in the thread                                                     |
| sender       | 1..1        | a reference to a `RelatedPerson` or `Practitioner` (must be individual for auditability)                  |
| recipient    | 0..*        | Unused — thread participants are defined on `CommunicationRequest.recipient`                               |
| payload      | 1..*        | Message or attachment, one of `contentString` or `contentAttachment`                                      |

##### Auditability

The `Communication.sender` must always be an individual (`Practitioner` or `RelatedPerson`) to ensure auditability. Every message in the system must have an identifiable person as the sender. This applies even in team-level messaging scenarios - while the thread may be owned by a CareTeam, each individual message is sent by a specific person.

##### Examples

* [Reply-Manu-to-Kees](Communication-Reply-Manu-to-Kees.html) - Practitioner replies to RelatedPerson
* [Reply-Kees-to-Netwerk](Communication-Reply-Kees-to-Netwerk.html) - RelatedPerson to CareTeam
* [Clinic-Response-to-Pharmacy](Communication-Clinic-Response-to-Pharmacy.html) - Team messaging: reply
* [Pharmacy-Followup-by-Pieter](Communication-Pharmacy-Followup-by-Pieter.html) - Team messaging: different team member follows up

##### Attachment

The `Attachment` resource is used to:

* Add documents to the `CommunicationRequest` and `Communication` resource.

#### Task

**Profile:** [OZOTask](StructureDefinition-ozo-task.html)

The `Task` resource is used to:
* Notify the recipient about a new message.
* Check the status of the thread

##### Fields

| field   | Cardinality | description                                        |
|---------|-------------|----------------------------------------------------|
| status  | 1..1        | requested                                          |
| basedOn | 1..1        | Reference to a `CommunicationRequest`              |
| intent  | 1..1        | `order`                                            |
| for     | 1..1        | a reference to a `Patient`                         |
| owner   | 1..1        | a reference to a `RelatedPerson` or `Practitioner` |

##### Examples
* [Notify-Kees-Groot](Task-Notify-Kees-Groot.html)
* [Notify-Manu-van-Weel](Task-Notify-Manu-van-Weel.html)
* [Notify-Mark-Benson](Task-Notify-Mark-Benson.html)

#### AuditEvent

**Profile:** [OZOAuditEvent](StructureDefinition-OZOAuditEvent.html) (custom profile for NEN7510 compliance)

The `AuditEvent` is used to:
* Update the `Task` status field as client of the OZO FHIR Api
* Provide NEN7510-compliant audit logging with W3C Trace Context support

For detailed information about NEN7510 compliance and audit logging, see [AuditEvent for NEN7510 Compliance](auditevent-nen7510.html).

##### Examples
* [Manu-Read-Messages](AuditEvent-Manu-Read-Messages.html)
* [Mark-Read-Messages](AuditEvent-Mark-Read-Messages.html)
* [Kees-Read-Messages](AuditEvent-Kees-Read-Messages.html)
* [REST-Create](AuditEvent-REST-Create.html)
* [REST-Search](AuditEvent-REST-Search.html)
* [REST-Update-Denied](AuditEvent-REST-Update-Denied.html)
* [System-Read](AuditEvent-System-Read.html)

### Subscriptions

**Profile:** [Subscription](http://hl7.org/fhir/R4/subscription.html) (based on FHIR R4 Subscription resource)

The `Subscription` resource is used for clients of the OZO FHIR Api to receive updates about events in the changes in the FHIR Api:
* When Tasks are created for the users in the OZO platform
* When Tasks get updated in the OZO platform

### Diagram
{::nomarkdown}
{% include fhir-messages-datamodel.svg %}
{:/}

### Interaction with the OZO FHIR Api
The different interactions are described in the following guides:

* [Interaction - Creating Threads and Reading Messages](interaction-messaging.html)

