### The OZO platform from a functional perspective

The OZO platform connects care professionals with informal caregivers. The platform is able to create a link between the
formal healthcare network with the informal social environment of the patient. Hereby the OZO platform needs to cross
borders of healthcare and open up to the social context of the patents.

TODO: give a functional overview.

### The OZO care network datamodel

### About the name element.

Please refer to the following documentation of the Dutch name element:

* [NameInformation-v1.0(2017EN)](https://zibs.nl/wiki/NameInformation-v1.0(2017EN))

The FHIR API is based on FHIR R4 and makes use of the following FHIR resources:

#### Patient

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
* [Patient-4](Patient-4.html)

#### Related Person

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
* [RelatedPerson-5](RelatedPerson-5.html)

#### Practitioner

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
* [Practitioner-6](Practitioner-6.html)

#### CareTeam

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
* [CareTeam-9](CareTeam-9.html)

#### Organization

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

* [Organization-1](Organization-1.html)
* [Organization-2](Organization-2.html)
* [Organization-3](Organization-3.html)

### Diagram

{% include fhir-network-datamodel.svg %}


### Interaction with the OZO FHIR Api
The different interactions are described in the following guides:

* [Interaction - Creating the network](interaction-network.html)


### The OZO messaging datamodel

Messaging can be used within the OZO FHIR API. To achieve this, the following 2 FHIR Resources are used:

#### CommunicationRequest
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
* [CommunicationRequest-10](CommunicationRequest-10.html)

#### Communication
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

* [Communication-15](Communication-15.html)
* [Communication-18](Communication-18.html)

##### Attachment

The `Attachment` resource is used to:

* Add documents to the `CommunicationRequesr` and `Communication` resource.

#### Task
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
* [Task-11](Task-11.html)
* [Task-12](Task-12.html)
* [Task-13](Task-13.html)
* [Task-14](Task-14.html)
* [Task-18](Task-18.html)

#### AuditEvent
The `AuditEvent` is used to:
* Update the `Task` status field as client of the OZO FHIR Api 

##### Examples
* [AuditEvent-16](AuditEvent-16.html)
* [AuditEvent-17](AuditEvent-17.html)
* [AuditEvent-20](AuditEvent-20.html)

### Subscriptions

The `Subscription` resource is used for clients of the OZO FHIR Api to receive updates about events in the changes in the FHIR Api:
* When Tasks are created for the users in the OZO platform
* When Tasks get updated in the OZO platform

### Diagram

{% include fhir-messages-datamodel.svg %}

### Interaction with the OZO FHIR Api
The different interactions are described in the following guides:

* [Interaction - Creating Threads and Reading Messages](interaction-messaging.html)

