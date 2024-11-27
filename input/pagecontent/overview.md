# Overview

## The OZO platform from a functional perspective

The OZO platform connects care professionals with informal caregivers. The platform is able to create a link between the
formal healthcare network with the informal social environment of the patient. Hereby the OZO platform needs to cross
borders of healthcare and open up to the social context of the patents.

TODO: give a functional overview.

## The OZO care network datamodel

The FHIR API is based on FHIR R4 and makes use of the following FHIR resources:

### Patient

The patient represents the client in the domain, for each real-life patient only one single entity exists. The Patient
is primary identified by the BSN. Required fields:

| field                           | cardinality | description |
|---------------------------------|-------------|-------------|
| identifier[system="OZO/Person"] | 1..1        |             |

#### Identity mapping

The identifier of the Patient will be unique and _should_ the internal identifier of the patient in the OZO system.

### Related Person

The related person resource represents the relation between patient and a informal caregiver. For each _relationship_
between a patient and informal caregiver one related person exists. For each real-life person multiple related person
resources exist, one for each patient it has a caregiving relationship with.

| field                                                                    | cardinality | description                                                                                              |
|--------------------------------------------------------------------------|-------------|----------------------------------------------------------------------------------------------------------|
| identifier[system="OZO/NetworkRelation"] identifier[system="OZO/Person"] | 1..*        | The OZO assigned account id                                                                              |
| name                                                                     | 1..*        | The name field, as ZIB [NameInformation-v1.0(2017EN)](https://zibs.nl/wiki/NameInformation-v1.0(2017EN)) |
| patient                                                                  | 1..1        | The reference to the patient                                                                             | 

#### Identity mapping

The OZO FHIR RelatedPerson uses two identities to identify the RelatedPerson entity:

1. The internal account of the related person in the OZO system, this identifier is NOT unique for each relationship and
   identical for each OZO user account linked to a real-life person.
2. The relationship identifier in the OZO system, unique for each relationship between a the OZO related person account
   and the patient.

### Practitioner

The practitioner represents a health care professional that has a relationship with one or more patients. The
practitioner is linked to the patient by the care team.

| field                       | cardinality | description                                                                                              |
|-----------------------------|-------------|----------------------------------------------------------------------------------------------------------|
| identifier[system=UZI\|BIG] | 1..1        |                                                                                                          |
| name                        | 1..*        | The name field, as ZIB [NameInformation-v1.0(2017EN)](https://zibs.nl/wiki/NameInformation-v1.0(2017EN)) |

### CareTeam

The care team is the resource that binds the patient to the related person(s) and practitioners. There _should_ exist
only one care team resource for each patient in the system. Multiple care team resources _could_ exist if specific use
cases require this.

| field       | Cardinality | description                              |
|-------------|-------------|------------------------------------------|
| patients    | 1           | reference to the patient                 |
| participant | 1..*        | a reference to a Patient or Practitioner |


## Diagram

{% include fhir-network-datamodel.svg %}
<br clear="all"/>


## Interaction with the OZO FHIR Api
The different interactions are described in the following guides:
* [use case network](usecase-network.html)


## The OZO messaging datamodel

Messaging can be used within the OZO FHIR API. To achieve this, the following 2 FHIR Resources are used:

### CommunicationRequest
The `CommunicationRequest` Resource is used to:

* Initially request a thread
* Group messages into a thread
* Manage the status of a thread in a clear place
* Manage the participants of a thread in a clear place
* Display a list of threads for a Patient

### Communication
The `Communication` resource is used to:

* Place a message in a thread.

### Task
The `Task` resource is used to:
* Notify the recipient about a new message.
* Check the status of the thread

### AuditEvent
The `AuditEvent` is used to:
* Update the `Task` status field as client of the OZO FHIR Api 

## Subscriptions

The `Subscription` resource is used for clients of the OZO FHIR Api to receive updates about events in the changes in the FHIR Api:
* When Tasks are created for the users in the OZO platform
* When Tasks get updated in the OZO platform

## Diagram

{% include fhir-messages-datamodel.svg %}
<br clear="all"/>

## Interaction with the OZO FHIR Api
The different interactions are described in the following guides:
* [use case messaging](usecase-messages.html)

