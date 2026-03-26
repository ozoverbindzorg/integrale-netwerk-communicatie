Team-to-team messaging enables organizations (pharmacies, clinics, hospitals) to communicate as units while maintaining individual auditability. This pattern uses the [OZOOrganizationalCareTeam](StructureDefinition-ozo-organizational-careteam.html) profile to represent organizational teams — these are CareTeams without a patient subject, linked to a managing `Organization`.

For individual messaging (RelatedPerson ↔ Practitioner), see [Individual Messaging](interaction-messaging.html).

### Key Concepts

1. **CareTeam as Reply-To Address**: The `CommunicationRequest` uses the `senderCareTeam` extension to specify a `CareTeam` as the reply-to address. This is needed because FHIR R4 `CommunicationRequest.sender` does not allow CareTeam references. The extension:
   - Provides the **reply-to address** for the conversation
   - Grants **team-level authorization** for message management
   - Enables the **shared inbox pattern**

2. **Individual Auditability**: All sender fields remain individuals:
   - `CommunicationRequest.requester` is always an individual (who initiated the thread)
   - `CommunicationRequest.sender` is always an individual (same as requester)
   - `Communication.sender` is always an individual (who sent each message)
   - Every action is traceable to a specific person

3. **Reply-To Discovery**: When replying to a team message:
   - Read the `senderCareTeam` extension from the `CommunicationRequest` to find the reply-to `CareTeam`
   - Send the reply to that `CareTeam` as recipient

### Roles

This IG distinguishes the following roles when processing team-to-team messages:
* **Team A** (initiating team), e.g. a pharmacy — operates through the **OZO platform**.
* **Team B** (receiving team), e.g. a clinic — operates through the **OZO platform**.
* The **OZO FHIR Api** that executes actions triggered by CRUD actions on `CommunicationRequest`, `Communication`, `Task` and `AuditEvent`.

Both teams use the **OZO platform**. Unlike individual messaging, there is no OZO client involved — both sides are practitioners.

### Prerequisite, Subscriptions

The following Subscription objects are created by the OZO platform for each team:
* `CommunicationRequest?id`
* `Communication?id`
* `Task?status=requested` (the AAA proxy automatically scopes this to the current user's ownership)

#### Notify-then-pull pattern

In the Netherlands, healthcare data must not be pushed in subscription notifications. All subscriptions use the **notify-then-pull** pattern:

1. The FHIR server sends an **empty notification** (no resource payload) to the subscriber's endpoint
2. The subscriber **pulls** the changed resource by performing a FHIR read or search

This means `channel.payload` must be left empty. The notification only signals that something matched the subscription criteria — the subscriber is responsible for fetching the actual data.

#### Example Subscription resources

* [Subscription-Communication](Subscription-Subscription-Communication.html) — new message detection
* [Subscription-Task-Unread](Subscription-Subscription-Task-Unread.html) — unread message tracking
* [Subscription-CommunicationRequest](Subscription-Subscription-CommunicationRequest.html) — thread lifecycle

### Subscription behavior

Each subscription serves a different purpose. Understanding when notifications fire is critical for correct client implementation:

| Subscription              | Purpose                                                                                             | Fires when                                                         |
|---------------------------|-----------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| `Communication?id`        | **New message notification.** This is the primary mechanism for detecting new messages in a thread. | A new `Communication` is created (POST).                           |
| `CommunicationRequest?id` | Thread lifecycle changes.                                                                           | A `CommunicationRequest` is created or its status changes.         |
| `Task?status=requested`   | Read status changes. **Not suitable for new-message detection.**                                    | A `Task` status changes to REQUESTED (e.g. COMPLETED → REQUESTED). |

> **Important:** The `Task` resource functions as a **read/unread indicator**, not as a message notification mechanism. When a new message arrives and the Task is already in status `requested` (unread), the OZO FHIR Api sets it to `requested` again — which is a no-op. HAPI FHIR does not create a new resource version when nothing changes, so **no subscription notification is sent**.
>
> To detect new messages, clients **must** subscribe to `Communication`. The `Task` subscription is only useful for observing read-status transitions.
{:.stu-note}

### Create a new team thread

A practitioner from Team A creates a new thread addressed to Team B. The process looks as follows:

* The **OZO platform** (on behalf of Team A practitioner) creates a new `CommunicationRequest` object, the following fields are set:
  * The `requester` is the `Practitioner` who initiates the conversation (for auditability)
  * The `sender` is the same `Practitioner` (individual sender)
  * The `extension[senderCareTeam]` is set to the `CareTeam` of Team A (reply-to address for team-level authorization)
  * The `subject` is the `Patient` reference
  * The `recipient` is the `CareTeam` of Team B
  * The `status` is set to ACTIVE
  * The `payload` contains the initial message
* The **OZO FHIR Api** creates a `Task` for each member of Team B's `CareTeam`:
    * The `status` is set to REQUESTED
    * The `intent` is set to ORDER
    * The `basedOn` is set to the `CommunicationRequest` reference
    * The `subject` is set to the `Patient` reference
    * The `owner` is set to the individual `CareTeam` member
* The **OZO platform** (Team B side) receives the new `CommunicationRequest` and `Task` by Subscription:
  * The `CommunicationRequest` subscription notifies Team B of the new thread
  * The `Task` (status REQUESTED) tracks the unread state per team member
  * The thread appears in Team B's shared inbox for all team members

### Respond to a team thread (Team B replies)

A practitioner from Team B responds to the thread. The reply is addressed to Team A's `CareTeam`, which is discovered from the `senderCareTeam` extension on the original `CommunicationRequest`.

* The **OZO platform** (on behalf of Team B practitioner) creates a new `Communication` with the following fields:
  * The `partOf` is set to the reference of the `CommunicationRequest`
  * The `inResponseTo` is set to the reference of the previous `Communication` being replied to
  * The `sender` is set to the `Practitioner` from Team B (individual auditability)
  * The `recipient` is set to the `CareTeam` of Team A (read from `CommunicationRequest.extension[senderCareTeam]`)
  * The `payload` consists of text and optionally attachments
  * The `status` is set to COMPLETED
* The **OZO FHIR Api** does the following:
  * For each member of Team A's `CareTeam` (the recipient) and not the sender:
    * An existing task is queried depending on the status, the following action is taken:
      * if a task exists:
        * The status is set to REQUESTED
      * if a task does not exist, a new one is created with the following properties:
        * The `status` is set to REQUESTED
        * The `intent` is set to ORDER
        * The `basedOn` is set to the `CommunicationRequest` reference
        * The `subject` is set to the `Patient` reference
        * The `owner` is set to the individual `CareTeam` member
  * For each member of Team B's `CareTeam` who is not the sender:
    * The existing task status is set to COMPLETED (the team member's colleague has responded)
* The **OZO platform** (Team A side) receives a notification about the new `Communication` by Subscription:
  * The new message appears in Team A's shared inbox
  * Any practitioner from Team A can view the response
  * The `Task` status change (COMPLETED → REQUESTED) updates the unread indicator, but only if the previous message was already read. If the Task was already REQUESTED, no Task notification is sent — the `Communication` subscription ensures the message is always detected.

### Follow-up from a different team member (Team A replies)

A *different* practitioner from Team A follows up on the thread. This demonstrates that any team member can participate in the conversation.

* The **OZO platform** (on behalf of a different Team A practitioner) creates a new `Communication` with the following fields:
  * The `partOf` is set to the reference of the `CommunicationRequest`
  * The `inResponseTo` is set to the reference of the previous `Communication`
  * The `sender` is set to the different `Practitioner` from Team A (individual auditability — note this is a different person than the original requester)
  * The `recipient` is set to the `CareTeam` of Team B
  * The `payload` consists of text and optionally attachments
  * The `status` is set to COMPLETED
* The **OZO FHIR Api** processes tasks the same way as described above:
  * Team B members get REQUESTED tasks
  * Other Team A members get COMPLETED tasks (their colleague responded)

### Marking messages as read

When a practitioner reads a message in a team thread:
* The **OZO platform** creates an `AuditEvent` with the following properties:
  * The `type` is set to `http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle|access`
  * The `action` is set to 'R'
  * The `recorded` field is set to the current timestamp
  * The `agent.who` field is set to the `Practitioner` who read the message
  * The `entity.what` field has two values:
    * A reference to the `Communication`
    * A reference to the `CommunicationRequest`
* The **OZO FHIR Api** does the following:
  * The `Task` is queried for the `Practitioner` as part of the agent.who of the `AuditEvent`
  * The `Task` status is set to COMPLETED
* When one practitioner of the `CareTeam` reads the message, the message is marked as read for all the members in the `CareTeam`.

### Interaction diagram

The diagram below displays the team-to-team messaging flow, including thread creation and responses from both teams.
{::nomarkdown}
{% include fhir-team-messaging-interaction.svg %}
{:/}

---

### Example: Pharmacy to Clinic Communication

The following walkthrough shows a concrete example with Apotheek de Pil (Pharmacy A) and Huisarts Amsterdam (Clinic B).

#### Step 1: Pharmacy initiates thread

A pharmacist (A.P. Otheeker) from Apotheek de Pil sends a message to Huisarts Amsterdam about a patient's medication — see [Pharmacy-to-Clinic](CommunicationRequest-Pharmacy-to-Clinic.html) for the full `CommunicationRequest`.

The **OZO FHIR Api** creates a `Task` (status `requested`) for each Clinic B member — see [Notify-Manu-van-Weel](Task-Notify-Manu-van-Weel.html) for an example of a Task resource.

**Notifications fired:**
* `CommunicationRequest` subscription → Clinic B notified of new thread
* `Task?status=requested` subscription → each Clinic B practitioner notified of unread thread

#### Step 2: Manu van Weel reads the message and replies

Dr. Manu van Weel from the clinic reads the message. The **OZO platform** creates an `AuditEvent` — see [Manu-Read-Messages](AuditEvent-Manu-Read-Messages.html) for a similar example.

The **OZO FHIR Api** marks the Tasks as completed. Because this is a team message, all Clinic B Tasks are completed (team-wide read):
* Task (for Manu van Weel): status → `completed` (was: `requested`)
* Task (for Mark Benson): status → `completed` (was: `requested`, team-wide read)
* Task (for Johan van den Berg): status → `completed` (was: `requested`, team-wide read)

Manu then replies. The reply goes to the pharmacy team (read from `CommunicationRequest.extension[senderCareTeam]`) — see [Clinic-Response-to-Pharmacy](Communication-Clinic-Response-to-Pharmacy.html) for the full `Communication`.

The **OZO FHIR Api** creates/updates Tasks for Pharmacy A members:
* Task (for A.P. Otheeker): status → `requested`
* Task (for Pieter de Vries): status → `requested`

**Notifications fired:**
* `Communication` subscription → Pharmacy A practitioners notified of new message
* `Task?status=requested` subscription → each Pharmacy A practitioner notified of unread message

#### Step 3: Different pharmacy practitioner follows up

A.P. Otheeker has not read the reply yet (Task still REQUESTED). Pieter de Vries reads it and responds, demonstrating that any team member can participate — see [Pharmacy-Followup-by-Pieter](Communication-Pharmacy-Followup-by-Pieter.html) for the full `Communication`.

The **OZO FHIR Api** updates Tasks:

**Pharmacy A Tasks:**
* Task (for A.P. Otheeker): status → `completed` (was: `requested`, team-wide read)
* Task (for Pieter de Vries): status → `completed` (Pieter is the sender)

**Clinic B Tasks:**
* Task (for Manu van Weel): status → `requested` (was: `completed`)
* Task (for Mark Benson): status → `requested` (was: `completed`)
* Task (for Johan van den Berg): status → `requested` (was: `completed`)

**Notifications fired:**
* `Communication` subscription → Clinic B practitioners notified of new message (always fires)
* `Task?status=requested` subscription → each Clinic B practitioner notified (status changed from COMPLETED to REQUESTED)

> **Note:** If Clinic B had not yet read the previous message (Tasks still REQUESTED), the Task update would be a no-op and no Task notification would be sent. The `Communication` subscription ensures the new message is always detected regardless of read status.
{:.stu-note}

---

### Query Patterns

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

**Find threads initiated by my team:**
```
GET /CommunicationRequest?_has:Extension:url=http://ozoverbindzorg.nl/fhir/StructureDefinition/ozo-sender-careteam&sender-careteam=CareTeam/Pharmacy-A
```

---

### Examples

#### Subscriptions
* [Subscription-Communication](Subscription-Subscription-Communication.html) - New message detection
* [Subscription-Task-Unread](Subscription-Subscription-Task-Unread.html) - Unread message tracking
* [Subscription-CommunicationRequest](Subscription-Subscription-CommunicationRequest.html) - Thread lifecycle

#### Messaging resources
* [Pharmacy-A](CareTeam-Pharmacy-A.html) - Pharmacy team for team-level messaging
* [Clinic-B](CareTeam-Clinic-B.html) - Clinic team for team-level messaging
* [Pharmacy-to-Clinic](CommunicationRequest-Pharmacy-to-Clinic.html) - Team-to-team thread
* [Clinic-Response-to-Pharmacy](Communication-Clinic-Response-to-Pharmacy.html) - First reply from clinic
* [Pharmacy-Followup-by-Pieter](Communication-Pharmacy-Followup-by-Pieter.html) - Follow-up from different team member

For detailed analysis of the addressing solution, see [FHIR Addressing Analysis](fhir-addressing-analysis.html).
