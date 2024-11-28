The messaging interaction consists of the following parts:
* Creating a thread
* Sending messages
* Receiving new messages
* Informing the OZO platform about messages being read.

### Roles
This IG distinguises the following roles when processing messages:
* The OZO platform, the environment where practitioners receive and respond to messages from caregivers.
* The OZO FHIR API that executes actions triggered by CRUD actions on CommunicationRequest, Communication, Task and AuditEvent.
* The OZO client, an environment where caregivers create, recieve and respond to messages in communication with the practitioners.

### Prerequisite, Subscriptions
The following Subscription objects are created by the OZO platform:
* CommunicationRequest?id
* Communication?id
* Task?id

The following Subscription are likely to be created by the ZO client:
* Task?owner=RelatedPerson/123&status=REQUESTED

### Create a new thread, the initial question
As client of the OZO FHIR Api can create a new thread. The process of creating a new thread looks as follows:
* The OZO client creates a new CommunicationRequest object, the following fields are set:
  * The requester is the RelatePerson
  * The subject is the Patient reference from the RelatedPerson
  * The recipient is the CareTeam of the related person.
  * The status is set to DRAFT
  * _The payload contains the initial message_
* The OZO FHIR API does the following (AS IMPLEMENTED, CHECK IF CORRECT):
  * For each member of the CareTeam as part of recipient a new Task is created, the Task has the following fields:
    * The status is set to REQUESTED is the member is not the sender, else COMPLETED
    * The intent is set to ORDER
    * The basedOn is set to the CommunicationRequest reference.
    * The subject is set to the Patient reference
    * The owner is set to the recipient.
* The OZO platform receives the new CommunicationRequest (by Subscription) (CHECK IF IMPLEMENTED THIS WAY):
  * The OZO platform presents the new CommunicationRequest to the recipient
  * The OZO platform accepts the CommunicationRequest by setting the status to ACTIVE

### Respond to a message from the OZO platform
A practitioner in the OZO platform responds to a message from a caregiver by the following actions:
* The OZO platform creates a new Communication with the following fields:
  * The partOf is set to the reference of the CommunicationRequest.
  * The sender is set to the reference of the Practitioner
  * The recipient is set to the reference of the RelatedPerson
  * The payload consists of both text as the message and additionally multiple attachments such as PDF.
* The OZO FHIR API does the following:
  * For each member of the CareTeam as part of recipient and not the sender:
    * An existing task is queried depending on the status, the following action is taken:
      * if a task exists:
        * The status is set to REQUESTED is the member is not the sender, else COMPLETED
      * if a task does not exist, a new one is created with the following properties: 
        * The status is set to REQUESTED
        * The intent is set to ORDER
        * The basedOn is set to the CommunicationRequest reference.
        * The subject is set to the Patient reference
        * The owner is set to the recipient.
* The OZO client receives a notification about a new Task and takes the following action:
  * The OZO client delivers the task to the care giver, the care giver marks the message as read.
  * The OZO client creates and AuditEvent with the following properies:
    * the type is set to `http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle|access`
    * the action is set to 'R'
    * the recorded field is set to 'now()'
    * the agent.who field is set to the RelatedPerson
    * the entity.what field has two values:
      * a reference to the Communication
      * a reference to the CommunicationRequest
* The OZO FHIR API does the following:
  * The Task is queried for the RelatedPerson as part of the agent.who of the AuditEvent
  * The Task status is set to COMPLETED
* The OZO platform receives the update of the Task and does the following:
  * The message is marked as read by the RelatedPerson in the OZO platform.

### Respond to a message from the OZO client
A caregiver in the OZO platform responds to a message from a practitioner by the following actions:
* The OZO platform creates a new Communication with the following fields:
  * The partOf is set to the reference of the CommunicationRequest.
  * The sender is set to the reference of the RelatedPerson
  * The recipient is set to the reference of the CareTeam
  * The payload consists of both text as the message and additionally multiple attachments such as PDF.
* The OZO FHIR API does the following:
  * For each member of the CareTeam as part of recipient and not the sender:
    * An existing task is queried depending on the status, the following action is taken:
      * if a task exists:
        * The status is set to REQUESTED is the member is not the sender, else COMPLETED
      * if a task does not exist, a new one is created with the following properties: 
        * The status is set to REQUESTED
        * The intent is set to ORDER
        * The basedOn is set to the CommunicationRequest reference.
        * The subject is set to the Patient reference
        * The owner is set to the recipient.
* The OZO platform receives a notification about a new Task and takes the following action:
  * The OZO platform delivers the task to the practitioners in the CareTeam, as one practitioner of the CareTeam reads the message, the messages is marked as read for all the members in the CareTeam.
  * The OZO platform creates and AuditEvent with the following properties:
    * the type is set to `http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle|access`
    * the action is set to 'R'
    * the recorded field is set to 'now()'
    * the agent.who field is set to the Practitioner
    * the entity.what field has two values:
      * a reference to the Communication
      * a reference to the CommunicationRequest
* The OZO FHIR API does the following:
  * The Task is queried for the Practitioner as part of the agent.who of the AuditEvent
  * The Task status is set to COMPLETED
* The OZO client remains uninformed about the status of the message (CHECK IF CORRECT)

### Interaction diagram
The diagram below displays displays the creation of threads, and responding for both the practitioner and related
person.
{% include fhir-messaging-interaction.svg %}


