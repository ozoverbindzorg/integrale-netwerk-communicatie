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
| identifier[system="OZO/Person"] | 1..1        |                     |
| name                            | 1..*        | The name field, ZIB |
| gender                          | 1..1        |                     |
| birthDate                       | 1..1        |                     |
| active                          | 1..1        | true                |

##### Identity mapping

The identifier of the `Patient` _must_ be unique and _should_ the internal identifier of the patient in the OZO system.

##### Examples
* [Patient-H-de-Boer](Patient-H-de-Boer.html)

#### Related Person

**Profile:** [OZORelatedPerson](StructureDefinition-ozo-relatedperson.html)

The related person resource represents the relation between `Patient` and a informal caregiver (`RelatedPerson`). For
each _relationship_
between a patient and informal caregiver one related person exists. For each real-life person multiple related person
resources exist, one for each patient it has a caregiving relationship with.

| field                                                                    | cardinality | description                            |
|--------------------------------------------------------------------------|-------------|----------------------------------------|
| identifier[system="OZO/NetworkRelation"] identifier[system="OZO/Person"] | 1..*        | The OZO assigned account id            |
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
* [RelatedPerson-Kees-Groot](RelatedPerson-Kees-Groot.html)

#### Practitioner

**Profile:** [OZOPractitioner](StructureDefinition-ozo-practitioner.html)

The `Practitioner` represents a health care professional that has a relationship with one or more patients. The
practitioner is linked to the patient by the care team.

| field                       | cardinality | description         |
|-----------------------------|-------------|---------------------|
| identifier[system=UZI\|BIG] | 1..1        |                     |
| name                        | 1..1        | The name field, ZIB |
| active                      | 1..1        | true                |

#### Identity mapping

The identifier of the `Practitioner` _must_ be unique and _should_ the internal identifier of the patient in the OZO
system.

##### Examples
* [Practitioner-Manu-van-Weel](Practitioner-Manu-van-Weel.html)
* [Practitioner-Mark-Benson](Practitioner-Mark-Benson.html)
* [Practitioner-A-P-Otheeker](Practitioner-A-P-Otheeker.html)

#### CareTeam

**Profile:** [OZOCareTeam](StructureDefinition-ozo-careteam.html)

The `CareTeam` is the resource that binds the patient to the related person(s) and practitioners. There _should_ exist
only one care team resource for each patient in the system. Multiple care team resources _could_ exist if specific use
cases require this. A CareTeam has a set of `participants` that consists of a `member`. For practitioners, this
relationship _should_ also contain the `onBehalfOf` property, linking to the `Organization`, this maps the relation of
the `Patient` to different `Organization`s

| field       | Cardinality | description                                                               |
|-------------|-------------|---------------------------------------------------------------------------|
| subject     | 1..1        | reference to the `Patient`                                                |
| participant | 1..*        | a reference to a `Patient`, `RelatedPerson`, `Practitioner` or `CareTeam` |
| status      | 1..1        | "active"                                                                  |


##### Examples
* [CareTeam-H-de-Boer](CareTeam-H-de-Boer.html)

#### Organization

**Profile:** [OZOOrganization](StructureDefinition-ozo-organization.html)

The `Organization` resource represents the different organizations in the network. The relation between the Patient and
Organization is managed by the participant in the care team. Each member of type Practitioner has an onBehalfOf
reference to the Organization.

| field                  | Cardinality | description                    |
|------------------------|-------------|--------------------------------|
| identifier[system=ura] | 1..1        |                                |
| name                   | 1..1        | The name of the `Organization` |

#### Identity mapping

The identifier of the `Organization` _must_ be unique and _should_ the internal identifier of the patient in the OZO
system.

##### Examples

* [Organization-Ziekenhuis-Amsterdam](Organization-Ziekenhuis-Amsterdam.html)
* [Organization-Ziekenhuis-Amsterdam-2](Organization-Ziekenhuis-Amsterdam-2.html)
* [Organization-Huisarts-Amsterdam](Organization-Huisarts-Amsterdam.html)
* [Organization-Apotheek-de-Pil](Organization-Apotheek-de-Pil.html)

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
| requester | 1..1        | a reference to a `RelatedPerson` or `Practitioner`                   |
| recipient | 1..*        | a reference to a `RelatedPerson`, `Practitioner` or `CareTeam`       |
| payload   | 1..*        | Message or attachment, one of `contentString` or `contentAttachment` |

##### Examples
* [CommunicationRequest-Thread-Example](CommunicationRequest-Thread-Example.html)

#### Communication

**Profile:** [OZOCommunication](StructureDefinition-ozo-communication.html)

The `Communication` resource is used to:

* Place a message in a thread.

##### Fields

| field     | Cardinality | description                                                                                               |
|-----------|-------------|-----------------------------------------------------------------------------------------------------------|
| status    | 1..1        | preparation \| in-progress  \| not-done \| on-hold \| stopped \| completed \| entered-in-error \| unknown |
| partOf    | 1..1        | Reference to a `CommunicationRequest`                                                                     |
| sender    | 1..1        | a reference to a `RelatedPerson` or `Practitioner`                                                        |
| recipient | 1..*        | a reference to a `RelatedPerson`, `Practitioner` or `CareTeam`                                            |
| payload   | 1..*        | Message or attachment, one of `contentString` or `contentAttachment`                                      |

##### Examples

* [Communication-RelatedPerson-to-CareTeam](Communication-RelatedPerson-to-CareTeam.html)

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
* [Task-RelatedPerson-Example](Task-RelatedPerson-Example.html)
* [Task-Practitioner-Manu-Example](Task-Practitioner-Manu-Example.html)
* [Task-Practitioner-Mark-Example](Task-Practitioner-Mark-Example.html)

#### AuditEvent

**Profile:** [OZOAuditEvent](StructureDefinition-OZOAuditEvent.html) (custom profile for NEN7510 compliance)

The `AuditEvent` is used to:
* Update the `Task` status field as client of the OZO FHIR Api
* Provide NEN7510-compliant audit logging with W3C Trace Context support

For detailed information about NEN7510 compliance and audit logging, see [AuditEvent for NEN7510 Compliance](auditevent-nen7510.html).

##### Examples
* [AuditEvent-Practitioner-Manu-Access](AuditEvent-Practitioner-Manu-Access.html)
* [AuditEvent-Practitioner-Mark-Access](AuditEvent-Practitioner-Mark-Access.html)
* [AuditEvent-RelatedPerson-Access](AuditEvent-RelatedPerson-Access.html)
* [AuditEvent-REST-Create-Example](AuditEvent-REST-Create-Example.html)
* [AuditEvent-REST-Search-Example](AuditEvent-REST-Search-Example.html)
* [AuditEvent-REST-Update-Failure](AuditEvent-REST-Update-Failure.html)
* [AuditEvent-System-Access](AuditEvent-System-Access.html)

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

