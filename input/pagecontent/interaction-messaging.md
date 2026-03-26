This page covers individual messaging between RelatedPersons and Practitioners. For team-to-team messaging (e.g. pharmacy ↔ clinic), see [Team-to-Team Messaging](interaction-messaging-team.html).

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
* `Task?status=requested` (the AAA proxy automatically scopes this to the current user's ownership)

The following Subscription are likely to be created by the OZO client:
* `Communication?id` (for new message detection)
* `Task?status=requested` (for unread message tracking)

### Subscription behavior

Each subscription serves a different purpose. Understanding when notifications fire is critical for correct client implementation:

| Subscription              | Purpose                                                                                             | Fires when                                                                       |
|---------------------------|-----------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------|
| `Communication?id`        | **New message notification.** This is the primary mechanism for detecting new messages in a thread. | A new `Communication` is created (POST).                                         |
| `CommunicationRequest?id` | Thread lifecycle changes.                                                                           | A `CommunicationRequest` is created or its status changes (e.g. DRAFT → ACTIVE). |
| `Task?status=requested`   | Read status changes. **Not suitable for new-message detection.**                                    | A `Task` status changes to REQUESTED (e.g. COMPLETED → REQUESTED).               |

> **Important:** The `Task` resource functions as a **read/unread indicator**, not as a message notification mechanism. When a new message arrives and the Task is already in status `requested` (unread), the OZO FHIR Api sets it to `requested` again — which is a no-op. HAPI FHIR does not create a new resource version when nothing changes, so **no subscription notification is sent**.
>
> To detect new messages, clients **must** subscribe to `Communication`. The `Task` subscription is only useful for observing read-status transitions (e.g. when a message is marked as read via `AuditEvent`, the Task moves from REQUESTED → COMPLETED).
{:.stu-note}

#### Recommended subscriptions by use case

* **For new messages:** Subscribe to `Communication?id` (or `Communication?part-of=CommunicationRequest/xxx` for a specific thread).
* **For unread status:** Subscribe to `Task?status=requested`. This is safer than `Task?id` because:
  * The AAA proxy automatically rewrites the subscription criteria to scope it to the current user (adding `owner=Practitioner/x,CareTeam/y`), so the client does not need to include `owner` explicitly.
  * It avoids a **subscription storm** — a generic `Task?id` subscription fires for every Task change across all users, while `Task?status=requested` only fires for relevant transitions.

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
* The **OZO client** receives a notification about the new `Communication` by Subscription and presents the message to the caregiver.

> **Note:** The `Task` subscription is **not designed** for detecting new messages. If the Task was already in REQUESTED status (the previous message was not yet read), setting it to REQUESTED again is a no-op and no notification is sent. Always use the `Communication` subscription for new-message detection.
{:.stu-note}

#### Marking the message as read

* The caregiver reads the message in the **OZO client**.
* The **OZO client** creates an `AuditEvent` with the following properties:
  * The `type` is set to `http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle|access`
  * The `action` is set to 'R'
  * The `recorded` field is set to 'now()'
  * The `agent.who` field is set to the `RelatedPerson`
  * The `entity.what` field has two values:
    * A reference to the `Communication`
    * A reference to the `CommunicationRequest`
* The **OZO FHIR Api** does the following:
  * The `Task` is queried for the `RelatedPerson` as part of the agent.who of the `AuditEvent`
  * The `Task` status is set to COMPLETED
* The **OZO platform** receives the `Task` status change (REQUESTED → COMPLETED) by Subscription:
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
* The **OZO platform** receives a notification about the new `Communication` by Subscription:
  * The message appears for practitioners in the `CareTeam`.
  * When one practitioner of the `CareTeam` reads the message, the message is marked as read for all the members in the `CareTeam` (the `Task` status is set to COMPLETED).
  * The **OZO platform** does not create an `AuditEvent`.

> **Note:** If the `Task` was already in REQUESTED status (a previous message was not yet read), no `Task` notification is sent. The `Communication` subscription ensures the new message is always detected.
{:.stu-note}

* The **OZO client** remains uninformed about the status of the message.

### Interaction diagram
The diagram below displays the creation of threads, and responding for both the practitioner and related person.
{::nomarkdown}
{% include fhir-messaging-interaction.svg %}
{:/}

---

### Example: Kees Groot messages his care team

The following walkthrough shows a concrete example using patient H. de Boer's care network ([Netwerk-H-de-Boer](CareTeam-Netwerk-H-de-Boer.html)), which includes:
* **Kees Groot** (RelatedPerson, informal caregiver)
* **Manu van Weel** (Practitioner, Ziekenhuis Amsterdam)
* **Mark Benson** (Practitioner, Huisarts Amsterdam)
* **A.P. Otheeker** (Practitioner, Apotheek de Pil)

#### Step 1: Kees creates a thread (OZO client)

Kees Groot sends a message to the care team about a fracture report:

```
CommunicationRequest:
  status = draft
  subject = Patient/H-de-Boer
  requester = RelatedPerson/Kees-Groot
  recipient = CareTeam/Netwerk-H-de-Boer
  payload[0].contentString = "Thread created by RelatedPerson"
  payload[1].contentAttachment.title = "rapport_fractuur.pdf"
```

The **OZO FHIR Api** creates a `Task` for each CareTeam member (except the sender):

```
Task (for Manu van Weel):                    Task (for Mark Benson):
  status = requested                           status = requested
  intent = order                               intent = order
  basedOn = CommunicationRequest/Thread-Example  basedOn = CommunicationRequest/Thread-Example
  for = Patient/H-de-Boer                     for = Patient/H-de-Boer
  owner = Practitioner/Manu-van-Weel          owner = Practitioner/Mark-Benson

Task (for A.P. Otheeker):
  status = requested
  intent = order
  basedOn = CommunicationRequest/Thread-Example
  for = Patient/H-de-Boer
  owner = Practitioner/A-P-Otheeker
```

**Notifications fired:**
* `CommunicationRequest` subscription → OZO platform notified of new thread
* `Task?status=requested` subscription → each practitioner notified of unread thread

The **OZO platform** receives the `CommunicationRequest` and sets status to ACTIVE.

#### Step 2: Manu van Weel replies (OZO platform)

Practitioner Manu van Weel reads the message and replies:

```
Communication:
  partOf = CommunicationRequest/Thread-Example
  sender = Practitioner/Manu-van-Weel
  recipient = RelatedPerson/Kees-Groot
  payload.contentString = "Goedemorgen Kees, bedankt voor uw bericht. Ik heb het rapport bekeken en zal dit bespreken met het team."
```

The **OZO FHIR Api** updates Tasks:

```
Task (for Kees Groot):                        Task (for Manu van Weel):
  status = requested   ← unread for Kees       status = completed  ← Manu is the sender
  owner = RelatedPerson/Kees-Groot             owner = Practitioner/Manu-van-Weel
```

**Notifications fired:**
* `Communication` subscription → OZO client notified of new message (primary new-message mechanism)
* `Task?status=requested` subscription → Kees notified of unread message (only if Task status changed from COMPLETED to REQUESTED)

#### Step 3: Kees reads the message and the read receipt is created (OZO client)

Kees opens the message in the OZO client. The client creates an `AuditEvent`:

```
AuditEvent:
  type = http://terminology.hl7.org/CodeSystem/audit-event-type#rest "RESTful Operation"
  subtype = http://hl7.org/fhir/restful-interaction#read "read"
  action = R
  recorded = "2024-12-05T17:25:01+01:00"
  agent.who = RelatedPerson/Kees-Groot
  source.site = "OZO Client"
  entity[0].what = CommunicationRequest/Thread-Example
  entity[1].what = Communication/Reply-Manu-to-Kees
```

The **OZO FHIR Api** marks the Task as completed:

```
Task (for Kees Groot):
  status = completed   ← was: requested
  owner = RelatedPerson/Kees-Groot
```

**Notifications fired:**
* `Task?status=requested` subscription → no (Task moved to COMPLETED, not REQUESTED)
* The **OZO platform** detects the Task status change (REQUESTED → COMPLETED) and marks the message as read by Kees.

#### Step 4: Kees responds (OZO client)

Kees sends a follow-up message to the care team:

```
Communication:
  partOf = CommunicationRequest/Thread-Example
  sender = RelatedPerson/Kees-Groot
  recipient = CareTeam/Netwerk-H-de-Boer
  payload.contentString = "Bedankt voor de reactie, ik hoor graag wat het team ervan vindt."
```

The **OZO FHIR Api** updates Tasks for each CareTeam member:

```
Task (for Manu van Weel):                    Task (for Mark Benson):
  status = requested   ← was: completed        status = requested   ← was already requested (no-op!)
  owner = Practitioner/Manu-van-Weel          owner = Practitioner/Mark-Benson
```

**Notifications fired:**
* `Communication` subscription → OZO platform notified of new message (always fires)
* `Task?status=requested` subscription → Manu notified (status changed from COMPLETED to REQUESTED)
* `Task?status=requested` subscription → Mark **not** notified (status was already REQUESTED — no-op, no new version created)

> **Note:** This is why `Communication` is the primary new-message mechanism. Mark Benson had not yet read the previous message, so his Task was already REQUESTED. The FHIR server does not create a new version for a no-op update, and no Task notification is sent. The `Communication` subscription ensures Mark's OZO platform still shows the new message.
{:.stu-note}

---

### Examples

* [Thread-Example](CommunicationRequest-Thread-Example.html) - Thread created by RelatedPerson
* [Reply-Manu-to-Kees](Communication-Reply-Manu-to-Kees.html) - Practitioner replies to RelatedPerson
* [Reply-Kees-to-Netwerk](Communication-Reply-Kees-to-Netwerk.html) - RelatedPerson replies to CareTeam
* [Notify-Manu-van-Weel](Task-Notify-Manu-van-Weel.html) - Task tracking unread status for Manu
* [Notify-Kees-Groot](Task-Notify-Kees-Groot.html) - Task tracking unread status for Kees
* [Kees-Read-Messages](AuditEvent-Kees-Read-Messages.html) - AuditEvent for Kees reading a message

