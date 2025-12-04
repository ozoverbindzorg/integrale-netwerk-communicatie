The messaging interaction consists of the following parts:
* Creating a thread
* Sending messages
* Receiving new messages
* Informing about messages being read.

### Roles
This IG distinguishes the following roles when processing messages:
* The **OZO platform**, the environment where practitioners receive and respond to messages from caregivers.
* The  **OZO FHIR Api** that executes actions triggered by CRUD actions on `CommunicationRequest`, `Communication`, Task and AuditEvent.
* The **OZO client**, an environment where caregivers create, receive and respond to messages in communication with the practitioners.

### Prerequisite, Subscriptions
The following Subscription objects are created by the OZO platform:
* `CommunicationRequest?id`
* `Communication?id`
* `Task?id`

The following Subscription are likely to be created by the ZO client:
* `Task?owner=RelatedPerson/123&status=REQUESTED`

### Create a new thread, the initial question
As client of the  **OZO FHIR Api** can create a new thread. The process of creating a new thread looks as follows:
* The **OZO client** creates a new `CommunicationRequest` object, the following fields are set:
  * The requester is the `RelatedPerson`
  * The subject is the `Patient` reference from the `RelatedPerson`
  * The recipient is one of the participants of the Careteam
  * The status is set to DRAFT
  * _The payload contains the initial message_
* The  **OZO FHIR Api** does the following (AS IMPLEMENTED, CHECK IF CORRECT):
  * For each member of the `CareTeam` as part of recipient a new Task is created, the Task has the following fields:
    * The status is set to REQUESTED is the member is not the sender, else COMPLETED
    * The intent is set to ORDER
    * The basedOn is set to the `CommunicationRequest` reference.
    * The subject is set to the `Patient` reference
    * The owner is set to the recipient.
* The **OZO platform** receives the new `CommunicationRequest` by Subscription:
  * The **OZO platform** presents the new `CommunicationRequest` to the recipient
  * The **OZO platform** accepts the `CommunicationRequest` by setting the status to ACTIVE

### Respond to a thread from the OZO platform
A practitioner in the **OZO platform** responds to a message from a caregiver by the following actions:
* The **OZO platform** creates a new `Communication` with the following fields:
  * The partOf is set to the reference of the `CommunicationRequest`.
  * The sender is set to the reference of the `Practitioner`
  * The recipient is set to the reference of the `RelatedPerson`
  * The payload consists of both text as the message and additionally multiple attachments such as PDF.
* The  **OZO FHIR Api** does the following:
  * For each member of the `CareTeam` as part of recipient and not the sender:
    * An existing task is queried depending on the status, the following action is taken:
      * if a task exists:
        * The status is set to REQUESTED is the member is not the sender, else COMPLETED
      * if a task does not exist, a new one is created with the following properties: 
        * The status is set to REQUESTED
        * The intent is set to ORDER
        * The basedOn is set to the `CommunicationRequest` reference.
        * The subject is set to the `Patient` reference
        * The owner is set to the recipient.
* The **OZO client** receives a notification about a new Task and takes the following action:
  * The **OZO client** delivers the task to the care giver, the care giver marks the message as read.
  * The **OZO client** creates and AuditEvent with the following properies:
    * the type is set to `http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle|access`
    * the action is set to 'R'
    * the recorded field is set to 'now()'
    * the agent.who field is set to the `RelatedPerson`
    * the entity.what field has two values:
      * a reference to the `Communication`
      * a reference to the `CommunicationRequest`
* The  **OZO FHIR Api** does the following:
  * The Task is queried for the `RelatedPerson` as part of the agent.who of the AuditEvent
  * The Task status is set to COMPLETED
* The **OZO platform** receives the update of the Task and does the following:
  * The message is marked as read by the `RelatedPerson` in the OZO platform.

### Respond to a thread from the OZO client
A caregiver in the **OZO client** responds to a message from a practitioner by the following actions:
* The **OZO client** creates a new `Communication` with the following fields:
  * The partOf is set to the reference of the `CommunicationRequest`.
  * The sender is set to the reference of the `RelatedPerson`
  * The recipient is set to the reference of the `CareTeam`
  * The payload consists of both text as the message and additionally multiple attachments such as PDF.
* The  **OZO FHIR Api** does the following:
  * For each member of the `CareTeam` as part of recipient and not the sender:
    * An existing task is queried depending on the status, the following action is taken:
      * if a task exists:
        * The status is set to REQUESTED is the member is not the sender, else COMPLETED
      * if a task does not exist, a new one is created with the following properties: 
        * The status is set to REQUESTED
        * The intent is set to ORDER
        * The basedOn is set to the `CommunicationRequest` reference.
        * The subject is set to the `Patient` reference
        * The owner is set to the recipient.
* The **OZO platform** receives a notification about a new Task and takes the following action:
  * The **OZO platform** delivers the task to the practitioners in the `CareTeam`, as one practitioner of the `CareTeam` reads the message, the messages is marked as read for all the members in the `CareTeam`.
  * The **OZO platform** does not create and AuditEvent.
* The **OZO client** remains uninformed about the status of the message.

### Interaction diagram
The diagram below displays displays the creation of threads, and responding for both the practitioner and related person.
{::nomarkdown}
{% include fhir-messaging-interaction.svg %}
{:/}

---

### Team-to-Team Messaging

Team-to-team messaging enables organizations (pharmacies, clinics, hospitals) to communicate as units while maintaining individual auditability. This pattern uses `CareTeam` resources to represent organizational teams.

#### Key Concepts

1. **CareTeam as Sender**: The `CommunicationRequest.sender` can be a `CareTeam`, which:
   - Provides the **reply-to address** for the conversation
   - Grants **team-level authorization** for message management
   - Enables the **shared inbox pattern**

2. **Individual Auditability**: Despite team-level messaging:
   - `CommunicationRequest.requester` is always an individual (who initiated the thread)
   - `Communication.sender` is always an individual (who sent each message)
   - Every action is traceable to a specific person

3. **Reply-To Discovery**: When replying to a team message:
   - Read the `CommunicationRequest.sender` to find the reply-to `CareTeam`
   - Send the reply to that `CareTeam` as recipient

#### Example: Pharmacy to Clinic Communication

**Step 1: Pharmacy initiates thread**

A pharmacist (A.P. Otheeker) from Apotheek de Pil sends a message to Huisarts Amsterdam about a patient's medication:

```
CommunicationRequest:
  status = active
  subject = Patient/H-de-Boer
  requester = Practitioner/A-P-Otheeker      ← Individual who initiated (auditability)
  sender = CareTeam/Pharmacy-A               ← Team reply-to address
  recipient = CareTeam/Clinic-B              ← Addressed to clinic team
  payload = "Can you review the medication list for interactions?"
```

**Step 2: Clinic practitioner replies**

Dr. Manu van Weel from the clinic responds. The reply goes to the pharmacy team (read from `CommunicationRequest.sender`):

```
Communication:
  partOf = CommunicationRequest/...
  sender = Practitioner/Manu-van-Weel        ← Individual auditability
  recipient = CareTeam/Pharmacy-A            ← From CommunicationRequest.sender
  payload = "I've reviewed the medications, no interactions found..."
```

**Step 3: Different pharmacy practitioner follows up**

Another pharmacist (Pieter de Vries) from the same team responds, demonstrating that any team member can participate:

```
Communication:
  partOf = CommunicationRequest/...
  inResponseTo = Communication/step2
  sender = Practitioner/Pieter-de-Vries      ← Different team member
  recipient = CareTeam/Clinic-B              ← Continue to clinic team
  payload = "Thank you for the quick response..."
```

#### Query Patterns

**Find messages for my team:**
```
GET /Communication?recipient=CareTeam/Pharmacy-A&_include=Communication:based-on
```

**Find all messages in a thread:**
```
GET /Communication?based-on=CommunicationRequest/thread-id&_sort=sent
```

**Find messages I sent:**
```
GET /Communication?sender=Practitioner/my-id
```

#### Examples

* [CareTeam-Pharmacy-A](CareTeam-Pharmacy-A.html) - Pharmacy team for team-level messaging
* [CareTeam-Clinic-B](CareTeam-Clinic-B.html) - Clinic team for team-level messaging
* [CommunicationRequest-Pharmacy-to-Clinic](CommunicationRequest-Pharmacy-to-Clinic.html) - Team-to-team thread
* [Communication-Team-Reply-1-Initial-Message](Communication-Team-Reply-1-Initial-Message.html) - Initial message
* [Communication-Team-Reply-2-Clinic-Response](Communication-Team-Reply-2-Clinic-Response.html) - Clinic reply
* [Communication-Team-Reply-3-Pharmacy-Followup](Communication-Team-Reply-3-Pharmacy-Followup.html) - Follow-up from different team member

For detailed analysis of the addressing solution, see [FHIR Addressing Analysis](fhir-addressing-analysis.html).

