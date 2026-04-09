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

In practice, a single Subscription is enough for most clients and platforms:

* **`Task?status=requested`** — **required**. Covers unread tracking and new-message notification for the recipient (the AAA proxy automatically scopes this to the current user's ownership). Use `Task?id` instead if you also need to detect **read receipts** (REQUESTED → COMPLETED transitions).

Optional additional subscriptions:

* `Communication?id` — *optional*. Only needed to see messages **you** sent yourself. Your own Task is set to COMPLETED on send and won't match `status=requested`, but the HTTP POST response usually gives you the same data.
* `CommunicationRequest?id` — *optional*. Only needed if you care about thread lifecycle events (DRAFT → ACTIVE approval, thread revoked/completed) separately from messages.

#### Notify-then-pull pattern

In the Netherlands, healthcare data must not be pushed in subscription notifications. All subscriptions use the **notify-then-pull** pattern:

1. The FHIR server sends an **empty notification** (no resource payload) to the subscriber's endpoint
2. The subscriber **pulls** the changed resource by performing a FHIR read or search

This means `channel.payload` must be left empty. The notification only signals that something matched the subscription criteria — the subscriber is responsible for fetching the actual data.

#### Example Subscription resources

* [Subscription-Task-Unread](Subscription-Subscription-Task-Unread.html) — unread tracking and new-message notification (required)
* [Subscription-Communication](Subscription-Subscription-Communication.html) — own sent messages (optional)
* [Subscription-CommunicationRequest](Subscription-Subscription-CommunicationRequest.html) — thread lifecycle (optional)

### Subscription behavior

Each subscription serves a different purpose. Understanding when notifications fire is critical for correct client implementation:

| Subscription              | Purpose                                                                                                             | Required? | Fires when                                                                                                                                                         |
|---------------------------|---------------------------------------------------------------------------------------------------------------------|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Task?status=requested`   | **Unread tracking and new-message notification for the recipient.** Primary mechanism.                              | Required  | Any change to a Task that matches `status=requested`. This includes status transitions to REQUESTED AND content changes (like `focus`) on Tasks already REQUESTED. |
| `Communication?id`        | Visibility of your own sent messages (sender's Task goes to COMPLETED and won't match `status=requested`).          | Optional  | A new `Communication` is created (POST).                                                                                                                           |
| `CommunicationRequest?id` | Thread lifecycle changes (DRAFT → ACTIVE, revoked, completed).                                                      | Optional  | A `CommunicationRequest` is created or its status changes.                                                                                                         |

> **Important:** When a new message arrives, the OZO FHIR Api updates the Task's `focus` field to reference the new `Communication`. This ensures `Task?status=requested` fires even when the task was already in REQUESTED status — the `focus` change creates a new resource version. The `focus` field also gives clients a direct pointer to the most recent unread message.
>
> This means `Task?status=requested` is a reliable single subscription for both unread tracking and new-message notification. The other two subscriptions are optional and only needed for specific edge cases.
{:.stu-note}

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
  * The payload consists of both text as the message and additionally multiple attachments such as PDF.
  * Note: `recipient` is not set — thread participants are defined on the `CommunicationRequest`.
* The  **OZO FHIR Api** does the following:
  * For each member of the `CareTeam` as part of recipient and not the sender:
    * An existing task is queried depending on the status, the following action is taken:
      * if a task exists:
        * The status is set to REQUESTED is the member is not the sender, else COMPLETED
        * The `focus` is updated to reference the new `Communication` (ensures the subscription fires even when status was already REQUESTED)
      * if a task does not exist, a new one is created with the following properties:
        * The status is set to REQUESTED
        * The intent is set to ORDER
        * The basedOn is set to the `CommunicationRequest` reference.
        * The subject is set to the `Patient` reference
        * The owner is set to the recipient.
        * The focus is set to the new `Communication` reference.
* The **OZO client** receives a notification about the new `Communication` by Subscription and presents the message to the caregiver.

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
  * The payload consists of both text as the message and additionally multiple attachments such as PDF.
  * Note: `recipient` is not set — thread participants are defined on the `CommunicationRequest`.
* The  **OZO FHIR Api** does the following:
  * For each member of the `CareTeam` as part of recipient and not the sender:
    * An existing task is queried depending on the status, the following action is taken:
      * if a task exists:
        * The status is set to REQUESTED is the member is not the sender, else COMPLETED
        * The `focus` is updated to reference the new `Communication` (ensures the subscription fires even when status was already REQUESTED)
      * if a task does not exist, a new one is created with the following properties:
        * The status is set to REQUESTED
        * The intent is set to ORDER
        * The basedOn is set to the `CommunicationRequest` reference.
        * The subject is set to the `Patient` reference
        * The owner is set to the recipient.
        * The focus is set to the new `Communication` reference.
* The **OZO platform** receives a notification about the new `Communication` by Subscription:
  * The message appears for practitioners in the `CareTeam`.
  * When one practitioner of the `CareTeam` reads the message, the message is marked as read for all the members in the `CareTeam` (the `Task` status is set to COMPLETED).
  * The **OZO platform** does not create an `AuditEvent`.

* The **OZO client** remains uninformed about the status of the message.

### Interaction diagram
The diagram below displays the creation of threads, and responding for both the practitioner and related person.
{::nomarkdown}
{% include fhir-messaging-interaction.svg %}
{:/}

---

### Example: Informal caregiver communicates with professionals

The following walkthrough shows a concrete example using patient H. de Boer's care network ([Netwerk-H-de-Boer](CareTeam-Netwerk-H-de-Boer.html)), which includes:
* **Kees Groot** (RelatedPerson — informal caregiver of H. de Boer, uses the OZO client)
* **Manu van Weel** (Practitioner, Ziekenhuis Amsterdam)
* **Mark Benson** (Practitioner, Huisarts Amsterdam)
* **A.P. Otheeker** (Practitioner, Apotheek de Pil)

#### Step 1: Kees creates a thread (OZO client)

Kees Groot sends a message to the care team about a fracture report — see [Thread-Example](CommunicationRequest-Thread-Example.html) for the full `CommunicationRequest`.

The **OZO FHIR Api** creates a `Task` (status `requested`) for each CareTeam member except the sender — see [Notify-Manu-van-Weel](Task-Notify-Manu-van-Weel.html) and [Notify-Mark-Benson](Task-Notify-Mark-Benson.html) for examples.

**Notifications fired:**
* `CommunicationRequest` subscription → OZO platform notified of new thread
* `Task?status=requested` subscription → each practitioner notified of unread thread

The **OZO platform** receives the `CommunicationRequest` and sets status to ACTIVE.

#### Step 2: Manu van Weel replies (OZO platform)

Practitioner Manu van Weel reads the message and replies — see [Reply-Manu-to-Kees](Communication-Reply-Manu-to-Kees.html) for the full `Communication`.

The **OZO FHIR Api** updates Tasks:
* [Notify-Kees-Groot](Task-Notify-Kees-Groot.html): status → `requested` (unread for Kees)
* [Notify-Manu-van-Weel](Task-Notify-Manu-van-Weel.html): status → `completed` (Manu is the sender)

**Notifications fired:**
* `Communication` subscription → OZO client notified of new message
* `Task?status=requested` subscription → Kees notified of unread message (status changed from COMPLETED to REQUESTED, and `focus` now points to the new message)

#### Step 3: Kees reads the message and the read receipt is created (OZO client)

Kees opens the message in the OZO client. The client creates an `AuditEvent` — see [Kees-Read-Messages](AuditEvent-Kees-Read-Messages.html) for the full resource.

The **OZO FHIR Api** marks the Task as completed:
* [Notify-Kees-Groot](Task-Notify-Kees-Groot.html): status → `completed` (was: `requested`)

**Notifications fired:**
* `Task?status=requested` subscription → no (Task moved to COMPLETED, not REQUESTED)
* The **OZO platform** detects the Task status change (REQUESTED → COMPLETED) and marks the message as read by Kees.

#### Step 4: Kees responds (OZO client)

Kees sends a follow-up message to the care team — see [Reply-Kees-to-Netwerk](Communication-Reply-Kees-to-Netwerk.html) for the full `Communication`.

The **OZO FHIR Api** updates Tasks for each CareTeam member — both status and `focus` (pointing to the new Communication):
* [Notify-Manu-van-Weel](Task-Notify-Manu-van-Weel.html): status → `requested` (was: `completed`), focus → new `Communication`
* [Notify-Mark-Benson](Task-Notify-Mark-Benson.html): status still `requested`, focus → new `Communication` (triggers new version)

**Notifications fired:**
* `Communication` subscription → OZO platform notified of new message
* `Task?status=requested` subscription → Manu notified (status changed from COMPLETED to REQUESTED)
* `Task?status=requested` subscription → Mark notified (focus changed — a new Task version is created and the Task still matches `status=requested`)

> **Note:** The `focus` update solves the no-op problem. Even when a practitioner hasn't read the previous message (Task already REQUESTED), updating `focus` to point to the new Communication creates a new resource version, so the Task subscription fires.
{:.stu-note}

---

### Examples

#### Subscriptions
* [Subscription-Communication](Subscription-Subscription-Communication.html) - New message detection
* [Subscription-Task-Unread](Subscription-Subscription-Task-Unread.html) - Unread message tracking
* [Subscription-CommunicationRequest](Subscription-Subscription-CommunicationRequest.html) - Thread lifecycle

#### Messaging resources
* [Thread-Example](CommunicationRequest-Thread-Example.html) - Thread created by RelatedPerson
* [Reply-Manu-to-Kees](Communication-Reply-Manu-to-Kees.html) - Practitioner replies to RelatedPerson
* [Reply-Kees-to-Netwerk](Communication-Reply-Kees-to-Netwerk.html) - RelatedPerson replies to CareTeam
* [Notify-Manu-van-Weel](Task-Notify-Manu-van-Weel.html) - Task tracking unread status for Manu
* [Notify-Kees-Groot](Task-Notify-Kees-Groot.html) - Task tracking unread status for Kees
* [Kees-Read-Messages](AuditEvent-Kees-Read-Messages.html) - AuditEvent for Kees reading a message

