Team-to-team messaging enables organizations (pharmacies, clinics, hospitals) to communicate as units while maintaining individual auditability. This pattern uses the [OZOOrganizationalCareTeam](StructureDefinition-ozo-organizational-careteam.html) profile to represent organizational teams: CareTeams without a patient subject, linked to a managing `Organization`.

For individual messaging (RelatedPerson ↔ Practitioner), see [Individual Messaging](interaction-messaging.html).

### Key Concepts

1. **Both teams are recipients**: `CommunicationRequest.recipient` lists every team participating in the thread: the addressed team (Team B) **and** the initiating team (Team A). The AAA proxy scopes access to threads, messages and Tasks on `recipient` (see [AAA Proxy](technical-aaa-proxy.html)). Without its own entry the initiating team could not read the thread it started, and the OZO FHIR Api could not address its members. The profile enforces this with the invariant `ozo-cr-sender-careteam-in-recipient`.

2. **CareTeam as Reply-To Address**: The `CommunicationRequest` uses the `senderCareTeam` extension to mark which of the recipient teams initiated the thread. This is needed because FHIR R4 `CommunicationRequest.sender` does not allow CareTeam references. The extension:
   - Identifies the **initiating team** (reply-to address) of the conversation
   - Grants **team-level authorization** for message management
   - Enables the **shared inbox pattern**

3. **Individual Auditability**: All sender fields remain individuals:
   - `CommunicationRequest.requester` is always an individual (who initiated the thread)
   - `CommunicationRequest.sender` is always an individual (same as requester)
   - `Communication.sender` is always an individual (who sent each message)
   - Every action is traceable to a specific person

4. **Sender's team**: For Task handling, the OZO FHIR Api resolves all recipient CareTeams of the thread and determines the **sender's team**: the recipient CareTeam(s) in which the sender is a participant. At thread creation this is the team in `extension[senderCareTeam]`. Members of the sender's team are treated as having read the message (team-wide read); members of the other recipient team(s) get an unread Task.

### Roles

This IG distinguishes the following roles when processing team-to-team messages:
* **Team A** (initiating team), e.g. a pharmacy, operates through the **OZO platform**.
* **Team B** (receiving team), e.g. a clinic, operates through the **OZO platform**.
* The **OZO FHIR Api** that executes actions triggered by CRUD actions on `CommunicationRequest`, `Communication`, `Task` and `AuditEvent`.

Both teams use the **OZO platform**. Unlike individual messaging, there is no OZO client involved: both sides are practitioners.

### Prerequisite, Subscriptions

In practice, a single Subscription is enough for most teams:

* **`Task?status=requested`**, **required**. Covers unread tracking and new-message notification for the team (the AAA proxy automatically scopes this to the team's ownership). Use `Task?id` instead if the platform also needs to detect **read receipts** (REQUESTED → COMPLETED transitions).

Optional additional subscriptions:

* `Communication?id`, *optional*. Only needed to see messages sent by **your own team members**. Their own Task is set to COMPLETED on send and won't match `status=requested`.
* `CommunicationRequest?id`, *optional*. Only needed if you care about thread lifecycle events (creation, revoked, completed) separately from messages.

#### Notify-then-pull pattern

In the Netherlands, healthcare data must not be pushed in subscription notifications. All subscriptions use the **notify-then-pull** pattern:

1. The FHIR server sends an **empty notification** (no resource payload) to the subscriber's endpoint
2. The subscriber **pulls** the changed resource by performing a FHIR read or search

This means `channel.payload` must be left empty. The notification only signals that something matched the subscription criteria; the subscriber is responsible for fetching the actual data.

#### Example Subscription resources

* [Subscription-Task-Unread](Subscription-Subscription-Task-Unread.html), unread tracking and new-message notification (required)
* [Subscription-Communication](Subscription-Subscription-Communication.html), own sent messages (optional)
* [Subscription-CommunicationRequest](Subscription-Subscription-CommunicationRequest.html), thread lifecycle (optional)

### Subscription behavior

Each subscription serves a different purpose. Understanding when notifications fire is critical for correct client implementation:

| Subscription              | Purpose                                                                                                      | Required? | Fires when                                                                                                                                                         |
|---------------------------|--------------------------------------------------------------------------------------------------------------|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Task?status=requested`   | **Unread tracking and new-message notification for the team.** Primary mechanism.                            | Required  | Any change to a Task that matches `status=requested`. This includes status transitions to REQUESTED AND content changes (like `focus`) on Tasks already REQUESTED. |
| `Communication?id`        | Visibility of messages sent by your own team members (sender's Task goes to COMPLETED).                      | Optional  | A new `Communication` is created (POST).                                                                                                                           |
| `CommunicationRequest?id` | Thread lifecycle changes (creation, revoked, completed).                                                      | Optional  | A `CommunicationRequest` is created or its status changes.                                                                                                         |

> **Important:** When a new message arrives, the OZO FHIR Api updates the Task's `focus` field to reference the new `Communication`. This ensures `Task?status=requested` fires even when the task was already in REQUESTED status: the `focus` change creates a new resource version. The `focus` field also gives clients a direct pointer to the most recent unread message.
>
> This means `Task?status=requested` is a reliable single subscription for both unread tracking and new-message notification. The other two subscriptions are optional and only needed for specific edge cases.
{:.stu-note}

### Create a new team thread

A practitioner from Team A creates a new thread addressed to Team B. The process looks as follows:

* The **OZO platform** (on behalf of Team A practitioner) creates a new `CommunicationRequest` object, the following fields are set:
  * The `requester` is the `Practitioner` who initiates the conversation (for auditability)
  * The `sender` is the same `Practitioner` (individual sender)
  * The `extension[senderCareTeam]` is set to the `CareTeam` of Team A (initiating team, reply-to address)
  * The `subject` is the `Patient` reference
  * The `recipient` lists the `CareTeam` of Team B **and** the `CareTeam` of Team A (the same reference as in `extension[senderCareTeam]`)
  * The `status` is set to ACTIVE
  * The `payload` contains the initial message
* The **OZO FHIR Api** creates a `Task` for each member of every recipient `CareTeam`:
    * The `status` is set to REQUESTED for the members of Team B, and to COMPLETED for the members of Team A (the sender's team: the requester sent the message and the colleagues are covered by the team-wide read)
    * The `intent` is set to ORDER
    * The `basedOn` is set to the `CommunicationRequest` reference
    * The `subject` is set to the `Patient` reference
    * The `owner` is set to the individual `CareTeam` member
    * The `focus` is not set at thread creation (there is no initial `Communication` yet; the thread's initial message is on `CommunicationRequest.payload`)
* The **OZO platform** (Team B side) receives the new `CommunicationRequest` and `Task` by Subscription:
  * The `CommunicationRequest` subscription notifies Team B of the new thread
  * The `Task` (status REQUESTED) tracks the unread state per team member
  * The thread appears in Team B's shared inbox for all team members

### Respond to a team thread (Team B replies)

A practitioner from Team B responds to the thread. Replies are not addressed individually: the `Communication` only references the thread, and the thread's `recipient` list defines who participates.

* The **OZO platform** (on behalf of Team B practitioner) creates a new `Communication` with the following fields:
  * The `partOf` is set to the reference of the `CommunicationRequest`
  * The `inResponseTo` is set to the reference of the previous `Communication` being replied to
  * The `sender` is set to the `Practitioner` from Team B (individual auditability)
  * The `payload` consists of text and optionally attachments
  * The `status` is set to COMPLETED
  * Note: `recipient` is not set; thread participants are defined on the `CommunicationRequest`.
* The **OZO FHIR Api** resolves the recipient `CareTeam`s of the `CommunicationRequest` and determines the sender's team: the recipient team in which `Communication.sender` is a participant (here Team B). Then:
  * For each member of the other recipient team(s) (here Team A):
    * An existing task is queried; depending on the result the following action is taken:
      * if a task exists:
        * The status is set to REQUESTED
        * The `focus` is updated to reference the new `Communication` (ensures the subscription fires even when status was already REQUESTED)
      * if a task does not exist, a new one is created with the following properties:
        * The `status` is set to REQUESTED
        * The `intent` is set to ORDER
        * The `basedOn` is set to the `CommunicationRequest` reference
        * The `subject` is set to the `Patient` reference
        * The `owner` is set to the individual `CareTeam` member
        * The `focus` is set to the new `Communication` reference
  * For each member of the sender's team (here Team B):
    * The existing task status is set to COMPLETED (a colleague has responded, team-wide read)
    * The `focus` is updated to reference the new `Communication`
* The **OZO platform** (Team A side) receives a notification by Subscription:
  * The new message appears in Team A's shared inbox
  * Any practitioner from Team A can view the response
  * The `Task?status=requested` subscription fires: the Team A Tasks moved to REQUESTED and `focus` points to the new `Communication`, which creates a new version even when the status was already REQUESTED.

### Follow-up from a different team member (Team A replies)

A *different* practitioner from Team A follows up on the thread. This demonstrates that any team member can participate in the conversation.

* The **OZO platform** (on behalf of a different Team A practitioner) creates a new `Communication` with the following fields:
  * The `partOf` is set to the reference of the `CommunicationRequest`
  * The `inResponseTo` is set to the reference of the previous `Communication`
  * The `sender` is set to the different `Practitioner` from Team A (individual auditability; note this is a different person than the original requester)
  * The `payload` consists of text and optionally attachments
  * The `status` is set to COMPLETED
* The **OZO FHIR Api** processes tasks the same way as described above. The sender is a participant of Team A, so Team A is the sender's team:
  * Team B members get REQUESTED tasks
  * Other Team A members get COMPLETED tasks (their colleague responded)

### Marking messages as read

When a practitioner reads a message in a team thread:
* The **OZO platform** creates an `AuditEvent` (a read receipt) with the following properties:
  * The `type` is set to `http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle|access`. This is the only type the OZO FHIR Api treats as a read receipt; the REST audit events the proxy creates itself use type `rest` and are ignored here. See [Manu-Read-Messages](AuditEvent-Manu-Read-Messages.html) for an example.
  * The `action` is set to 'R'
  * The `recorded` field is set to the current timestamp
  * The `agent.who` field is set to the `Practitioner` who read the message
  * The `entity.what` field has two values:
    * A reference to the `Communication`
    * A reference to the `CommunicationRequest`
* The **OZO FHIR Api** does the following:
  * The `Task` is queried for the `Practitioner` in `agent.who` of the `AuditEvent` and its status is set to COMPLETED
  * The reader's team is resolved from the recipient `CareTeam`s of the `CommunicationRequest`, and the Tasks of all other members of that team are set to COMPLETED as well (team-wide read)
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

A pharmacist (A.P. Otheeker) from Apotheek de Pil sends a message to Huisarts Amsterdam about a patient's medication; see [Pharmacy-to-Clinic](CommunicationRequest-Pharmacy-to-Clinic.html) for the full `CommunicationRequest`. Both teams are listed as `recipient`: [Clinic-B](CareTeam-Clinic-B.html) as addressed team and [Pharmacy-A](CareTeam-Pharmacy-A.html) as initiating team (also referenced in `extension[senderCareTeam]`).

The **OZO FHIR Api** creates a `Task` for each member of both teams:
* Clinic B (Manu van Weel, Mark Benson, Johan van den Berg): status `requested`; see [Notify-Manu-van-Weel](Task-Notify-Manu-van-Weel.html) for an example of a Task resource
* Pharmacy A (A.P. Otheeker, Pieter de Vries): status `completed` (sender's team)

**Notifications fired:**
* `CommunicationRequest` subscription → both teams notified of the new thread (Pharmacy A is a recipient too)
* `Task?status=requested` subscription → each Clinic B practitioner notified of unread thread

#### Step 2: Manu van Weel reads the message and replies

Dr. Manu van Weel from the clinic reads the message. The **OZO platform** creates a read receipt `AuditEvent` with type `iso-21089-lifecycle|access`; see [Manu-Read-Messages](AuditEvent-Manu-Read-Messages.html) for a similar example.

The **OZO FHIR Api** marks the Tasks as completed. Because this is a team message, all Clinic B Tasks are completed (team-wide read):
* Task (for Manu van Weel): status → `completed` (was: `requested`)
* Task (for Mark Benson): status → `completed` (was: `requested`, team-wide read)
* Task (for Johan van den Berg): status → `completed` (was: `requested`, team-wide read)

Manu then replies with a `Communication` whose `partOf` points to the thread; see [Clinic-Response-to-Pharmacy](Communication-Clinic-Response-to-Pharmacy.html) for the full resource. The **OZO FHIR Api** resolves the recipient teams of the thread: Manu is a participant of Clinic B, so Clinic B is the sender's team and Pharmacy A gets the unread Tasks.

**Pharmacy A Tasks:**
* Task (for A.P. Otheeker): status → `requested`, focus → new `Communication`
* Task (for Pieter de Vries): status → `requested`, focus → new `Communication`

**Clinic B Tasks:**
* Task (for Mark Benson, Johan van den Berg): status stays `completed` (colleague responded), focus → new `Communication`

**Notifications fired:**
* `Communication` subscription → Pharmacy A practitioners notified of new message
* `Task?status=requested` subscription → each Pharmacy A practitioner notified of unread message

#### Step 3: Different pharmacy practitioner follows up

A.P. Otheeker has not read the reply yet (Task still REQUESTED). Pieter de Vries reads it and responds, demonstrating that any team member can participate; see [Pharmacy-Followup-by-Pieter](Communication-Pharmacy-Followup-by-Pieter.html) for the full `Communication`. Pieter is a participant of Pharmacy A, so Pharmacy A is the sender's team.

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
* `Task?status=requested` subscription → each Clinic B practitioner notified (status changed from COMPLETED to REQUESTED AND focus updated to new Communication)

> **Note:** Even if Clinic B had not yet read the previous message (Tasks still REQUESTED), the `focus` update would still create a new Task version and fire the subscription. The `focus` field eliminates the no-op scenario.
{:.stu-note}

---

### Query Patterns

`Communication` links to its thread via `partOf`, so thread searches use the `part-of` search parameter. `based-on` is a different element and is not used in the OZO messaging model.

**Find messages for my team (via thread membership):**
```
GET /Communication?part-of:CommunicationRequest.recipient=CareTeam/Pharmacy-A
```
The AAA proxy applies this filter automatically for client access, so a plain `GET /Communication` returns the same result for a team member. `_include` is blocked for clients by the proxy; system access can add `&_include=Communication:part-of` to fetch the threads in the same call.

**Find all messages in a thread:**
```
GET /Communication?part-of=CommunicationRequest/thread-id&_sort=sent
```

**Find messages I sent:**
```
GET /Communication?sender=Practitioner/my-id
```

**Find all threads my team participates in:**
```
GET /CommunicationRequest?recipient=CareTeam/Pharmacy-A
```

**Find threads initiated by my team:**
```
GET /CommunicationRequest?sender-careteam=CareTeam/Pharmacy-A
```
`sender-careteam` is a custom search parameter defined by this IG on `extension[senderCareTeam]`; see [ozo-communicationrequest-sender-careteam](SearchParameter-ozo-communicationrequest-sender-careteam.html). The HAPI FHIR server needs the OZO package installed and existing threads reindexed once; see [Installing OZO Package in HAPI FHIR Server](hapi-installation.html#custom-search-parameters).

---

### Examples

#### Subscriptions
* [Subscription-Communication](Subscription-Subscription-Communication.html) - New message detection
* [Subscription-Task-Unread](Subscription-Subscription-Task-Unread.html) - Unread message tracking
* [Subscription-CommunicationRequest](Subscription-Subscription-CommunicationRequest.html) - Thread lifecycle

#### Messaging resources
* [Pharmacy-A](CareTeam-Pharmacy-A.html) - Pharmacy team for team-level messaging
* [Clinic-B](CareTeam-Clinic-B.html) - Clinic team for team-level messaging
* [Pharmacy-to-Clinic](CommunicationRequest-Pharmacy-to-Clinic.html) - Team-to-team thread, both teams as recipient
* [Clinic-Response-to-Pharmacy](Communication-Clinic-Response-to-Pharmacy.html) - First reply from clinic
* [Pharmacy-Followup-by-Pieter](Communication-Pharmacy-Followup-by-Pieter.html) - Follow-up from different team member
* [Manu-Read-Messages](AuditEvent-Manu-Read-Messages.html) - Read receipt (AuditEvent type `access`)

#### Search parameters
* [ozo-communicationrequest-sender-careteam](SearchParameter-ozo-communicationrequest-sender-careteam.html) - `CommunicationRequest?sender-careteam=` finds threads initiated by a team

For detailed analysis of the addressing solution, see [FHIR Addressing Analysis](fhir-addressing-analysis.html).
