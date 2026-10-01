### Changelog

Changes to this page per IG version. The full project history is on the [Changelog](history.html) page.

| Version | Date | Change |
| --- | --- | --- |
| 0.9.0 | 2026-10-01 | Team messaging model revised as proposed in [RFC - Team Messaging Model](rfc-team-messaging-model.html). `recipient` lists the addressed team only; the initiating team is in `extension[senderCareTeam]` and must not be repeated (invariant `ozo-cr-sender-careteam-not-in-recipient` replaces `ozo-cr-sender-careteam-in-recipient`). New `participant` search parameter over both elements; the proxy scopes on it. One `Task` per organizational team with `Task.owner` set to the CareTeam, instead of one per member. Every team-side action names its team: `extension[senderCareTeam]` on `Communication`, `agent.extension[careTeam]` on the read receipt. The OZO FHIR Api no longer infers the team from memberships (one-release transition). Walkthrough, diagram, query patterns and examples updated. Upgrade steps for the proxy and connecting platforms are on [AAA Proxy - Changes for 0.9.0](technical-aaa-proxy-0-9-0.html). |
| 0.8.4 | 2026-10-01 | Subscription criteria `Task?id`, `Communication?id` and `CommunicationRequest?id` replaced by `Task?`, `Communication?` and `CommunicationRequest?`. `id` is not a search parameter (the resource id parameter is `_id`); HAPI only accepted the old form because it drops parameters without a value. Note on the criteria form added. |
| 0.8.3 | 2026-10-01 | Sender's team tightened to the organizational recipient teams (no `subject`) that list the sender as participant; a patient care team never counts, so team-wide read never applies to a patient network. `extension[senderCareTeam]` must be an organizational team the requester participates in. `inResponseTo` marked as optional in the reply steps. It is a quote-reply link between messages; the thread link is `partOf` and the OZO FHIR Api does not use `inResponseTo`. Read receipt: two `entity` entries instead of "entity.what has two values"; the `CommunicationRequest` entity is required, the `Communication` entity optional. Note added that "mark as unread" is not part of the model. |
| 0.8.0 | 2026-09-17 | `CommunicationRequest.recipient` lists both teams, including the initiating team from `extension[senderCareTeam]` (invariant `ozo-cr-sender-careteam-in-recipient`). Task handling described per sender's team (team-wide read). Read receipts use AuditEvent type `access` (system iso-21089-lifecycle). Query patterns use `part-of` instead of `based-on`; new `sender-careteam` search parameter. Sequence diagram updated. |
| 0.7.6 | 2026-04-02 | `Task?status=requested` is the only required subscription; `Communication?id` and `CommunicationRequest?id` are optional. Explains how `Task.focus` (introduced in 0.7.5) makes the Task subscription fire on every new message. |
| 0.7.1 | 2026-03-30 | Added the `Task?id` note for platforms that also want to detect read receipts (REQUESTED → COMPLETED). |
| 0.6.2 | 2026-03-27 | `Communication.recipient` is no longer set on replies; thread participants live on `CommunicationRequest.recipient`. Team query pattern changed to `part-of:CommunicationRequest.recipient`. |
| 0.6.1 | 2026-03-27 | Inline pseudo-code replaced by links to the example resources. Added the "Subscription behavior" section and the Pharmacy A / Clinic B walkthrough with Tasks, AuditEvents and notifications per step. |
| 0.6.0 | 2026-03-27 | Page created, split off from Individual Messaging. Introduces `OZOOrganizationalCareTeam`, the `senderCareTeam` extension pattern and the team-to-team sequence diagram. |

---

Team-to-team messaging enables organizations (pharmacies, clinics, hospitals) to communicate as units while maintaining individual auditability. This pattern uses the [OZOOrganizationalCareTeam](StructureDefinition-ozo-organizational-careteam.html) profile to represent organizational teams: CareTeams without a patient subject, linked to a managing `Organization`.

For individual messaging (RelatedPerson ↔ Practitioner), see [Individual Messaging](interaction-messaging.html).

### Key Concepts

1. **Thread parties**: a thread has an addressed side and an initiating side. `CommunicationRequest.recipient` lists the **addressed** parties only: the addressed team (Team B), or individuals, or a patient care team. The **initiating** team (Team A) is referenced in `extension[senderCareTeam]` and nowhere else; the invariant `ozo-cr-sender-careteam-not-in-recipient` rejects a thread that repeats it in `recipient`. Both are thread parties: the custom search parameter [`participant`](SearchParameter-ozo-communicationrequest-participant.html) matches either element, and the AAA proxy scopes access to threads and messages on it (see [AAA Proxy](technical-aaa-proxy.html)). A member of the initiating team therefore sees the thread without the team being a recipient.

2. **CareTeam as Reply-To Address**: `extension[senderCareTeam]` on the `CommunicationRequest` names the organizational team that started the thread. This is needed because FHIR R4 `CommunicationRequest.sender` does not allow CareTeam references. The extension:
  - Identifies the **initiating team** (reply-to address) of the conversation
  - Grants **team-level authorization** for message management
  - Enables the **shared inbox pattern**
  - Must be an organizational `CareTeam` (no `subject`) the requester is a participant of; the AAA proxy rejects the thread otherwise

3. **Individual Auditability**: All sender fields remain individuals:
  - `CommunicationRequest.requester` is always an individual (who initiated the thread)
  - `CommunicationRequest.sender` is always an individual (same as requester)
  - `Communication.sender` is always an individual (who sent each message)
  - `AuditEvent.agent.who` is always an individual (who read a message)
  - Every action is traceable to a specific person

4. **One Task per team**: the OZO FHIR Api keeps one `Task` per organizational team that is a party of the thread, with `Task.owner` set to the `CareTeam`. The Task is the inbox state of the team, not of the person: `requested` means the team has an unread message, `completed` means a member has read or answered it. Every member of the team sees the team's Task (the proxy scopes `Task` on `owner=` with the user's own reference and their CareTeams). A practitioner who is in two teams of the same thread sees two Tasks, one per team, each with its own read state. Who in the team has personally seen a message stays visible in the read receipt `AuditEvent` resources, which is what NEN7510 asks for. Membership changes need no Task handling: a new member sees the team's Task immediately, a removed member loses access through the proxy scoping. Parties that are not organizational teams keep per-person Tasks:

   | Party in `recipient` or `extension[senderCareTeam]` | Tasks |
   | --- | --- |
   | Organizational CareTeam ([OZOOrganizationalCareTeam](StructureDefinition-ozo-organizational-careteam.html), no `subject`) | One Task, `owner` = the CareTeam |
   | Patient care team ([OZOCareTeam](StructureDefinition-ozo-careteam.html), with `subject`) | One Task per member, `owner` = the member (see [Individual Messaging](interaction-messaging.html)) |
   | Individual practitioner, related person or patient | One Task, `owner` = that person |

5. **Acting team**: every action a person performs for a team names that team. A message carries `Communication.extension[senderCareTeam]`; a read receipt carries `AuditEvent.agent.extension[careTeam]`. Both reference an [OZOOrganizationalCareTeam](StructureDefinition-ozo-organizational-careteam.html). The rule is the same for both: the extension is **required** when the sender or reader is a participant of at least one organizational team that is a party of the thread, and it must reference one of those teams. The AAA proxy rejects the message or receipt with 422 otherwise. The OZO FHIR Api acts on the named team only; the person's other teams in the same thread are treated like any other party. For a person who is in no organizational team of the thread (a related person, a patient, a practitioner addressed individually or through a patient care team) the extension is absent.

   > **Transition:** in 0.9.0 the OZO FHIR Api still infers the team when the extension is absent and exactly one candidate team exists, so an unchanged 0.8.x client keeps working for the common case. When more than one candidate exists and the extension is absent, the request is rejected with 422 instead of marking every team read, as 0.8.x did. The inference is removed in the release after 0.9.0; send the extension now.
   {:.stu-note}

### Roles

This IG distinguishes the following roles when processing team-to-team messages:
- **Team A** (initiating team), e.g. a pharmacy, operates through the **OZO platform**.
- **Team B** (receiving team), e.g. a clinic, operates through the **OZO platform**.
- The **OZO FHIR Api** that executes actions triggered by CRUD actions on `CommunicationRequest`, `Communication`, `Task` and `AuditEvent`.

Both teams use the **OZO platform**. Unlike individual messaging, there is no OZO client involved: both sides are practitioners.

### Prerequisite, Subscriptions

In practice, a single Subscription is enough for most teams:

- **`Task?status=requested`**, **required**. Covers unread tracking and new-message notification for the team. The AAA proxy rewrites the criteria to `owner=<practitioner>,<the practitioner's CareTeams>`, so the team's Task is in scope for every member. A platform receives one notification per team Task change instead of one per member. Use `Task?` (every Task change) instead if the platform also needs to detect **read receipts** (REQUESTED → COMPLETED transitions).

Optional additional subscriptions:

- `Communication?`, *optional*. Only needed to see messages sent by **your own team members**. The team's own Task is set to COMPLETED on send and won't match `status=requested`.
- `CommunicationRequest?`, *optional*. Only needed if you care about thread lifecycle events (creation, revoked, completed) separately from messages. The proxy rewrites the criteria with `participant=`, so threads the team initiated are included.

> **Criteria form:** `Subscription.criteria` is a FHIR search string. A criteria without parameters is written as `Task?`, the resource type followed by an empty parameter list. HAPI FHIR requires the `?`; a bare `Task` is rejected with "must be in the form {Resource Type}?[params]". Earlier versions of this page used `Task?id`, `Communication?id` and `CommunicationRequest?id`. `id` is not a search parameter (the resource id parameter is `_id`); HAPI only accepted that form because it drops parameters without a value. Replace it with the empty form.
{:.stu-note}

#### Notify-then-pull pattern

In the Netherlands, healthcare data must not be pushed in subscription notifications. All subscriptions use the **notify-then-pull** pattern:

1. The FHIR server sends an **empty notification** (no resource payload) to the subscriber's endpoint
2. The subscriber **pulls** the changed resource by performing a FHIR read or search

This means `channel.payload` must be left empty. The notification only signals that something matched the subscription criteria; the subscriber is responsible for fetching the actual data.

#### Example Subscription resources

- [Subscription-Task-Unread](Subscription-Subscription-Task-Unread.html), unread tracking and new-message notification (required)
- [Subscription-Communication](Subscription-Subscription-Communication.html), own sent messages (optional)
- [Subscription-CommunicationRequest](Subscription-Subscription-CommunicationRequest.html), thread lifecycle (optional)

### Subscription behavior

Each subscription serves a different purpose. Understanding when notifications fire is critical for correct client implementation:

| Subscription | Purpose | Required? | Fires when |
| --- | --- | --- | --- |
| `Task?status=requested` | **Unread tracking and new-message notification for the team.** Primary mechanism. | Required | Any change to the team's Task that matches `status=requested`. This includes status transitions to REQUESTED AND content changes (like `focus`) on a Task already REQUESTED. |
| `Communication?` | Visibility of messages sent by your own team members (the team's Task goes to COMPLETED). | Optional | A new `Communication` is created (POST). |
| `CommunicationRequest?` | Thread lifecycle changes (creation, revoked, completed). | Optional | A `CommunicationRequest` is created or its status changes. |

> **Important:** When a new message arrives, the OZO FHIR Api updates the Task's `focus` field to reference the new `Communication`. This ensures `Task?status=requested` fires even when the task was already in REQUESTED status: the `focus` change creates a new resource version. The `focus` field also gives clients a direct pointer to the most recent unread message.
>
> This means `Task?status=requested` is a reliable single subscription for both unread tracking and new-message notification. The other two subscriptions are optional and only needed for specific edge cases.
{:.stu-note}

### Create a new team thread

A practitioner from Team A creates a new thread addressed to Team B. The process looks as follows:

- The **OZO platform** (on behalf of Team A practitioner) creates a new `CommunicationRequest` object, the following fields are set:
  - The `requester` is the `Practitioner` who initiates the conversation (for auditability)
  - The `sender` is the same `Practitioner` (individual sender)
  - The `extension[senderCareTeam]` is set to the `CareTeam` of Team A (initiating team, reply-to address). This must be an organizational `CareTeam` (no `subject`) the requester is a participant of; the AAA proxy rejects the `CommunicationRequest` otherwise
  - The `subject` is the `Patient` reference
  - The `recipient` lists the `CareTeam` of Team B. Team A is **not** listed; the invariant `ozo-cr-sender-careteam-not-in-recipient` rejects the thread if it is
  - The `status` is set to ACTIVE
  - The `payload` contains the initial message
- The **OZO FHIR Api** creates one `Task` per thread party, here one per team:
    - The `owner` is the `CareTeam`
    - The `status` is set to REQUESTED for Team B's Task and to COMPLETED for Team A's Task (the initiating team: the requester sent the message)
    - The `intent` is set to ORDER
    - The `basedOn` is set to the `CommunicationRequest` reference
    - The `for` is set to the `Patient` reference
    - The `focus` is not set at thread creation (there is no initial `Communication` yet; the thread's initial message is on `CommunicationRequest.payload`)
- The **OZO platform** (Team B side) receives the new `CommunicationRequest` and `Task` by Subscription:
  - The `CommunicationRequest` subscription notifies Team B of the new thread
  - The `Task` (status REQUESTED, owner Team B) marks the thread unread in Team B's shared inbox
  - The thread appears for all Team B members; the proxy scopes on `participant=` and `owner=` with the team reference

### Respond to a team thread (Team B replies)

A practitioner from Team B responds to the thread. Replies are not addressed individually: the `Communication` only references the thread, and the thread parties (`recipient` plus `extension[senderCareTeam]` of the `CommunicationRequest`) define who takes part.

- The **OZO platform** (on behalf of Team B practitioner) creates a new `Communication` with the following fields:
  - The `partOf` is set to the reference of the `CommunicationRequest`
  - Optionally, `inResponseTo` references the specific earlier `Communication` this message replies to (a quote-reply). The OZO thread model does not need it: the message belongs to the thread via `partOf`, and the OZO FHIR Api does not use `inResponseTo` for Task handling. Platforms without a reply-to-message concept leave it out.
  - The `sender` is set to the `Practitioner` from Team B (individual auditability)
  - The `extension[senderCareTeam]` is set to the `CareTeam` of Team B (the acting team). Required because the sender is a participant of an organizational team of the thread; the AAA proxy rejects the message with 422 when it is missing or names a team that is not a party of the thread or not one of the sender's teams
  - The `payload` consists of text and optionally attachments
  - The `status` is set to COMPLETED
  - Note: `recipient` is not set; thread parties are defined on the `CommunicationRequest`.
- The **OZO FHIR Api** resolves the thread parties of the `CommunicationRequest` and the acting team from `extension[senderCareTeam]` (here Team B). Then, for every party:
  - The acting team (Team B): its Task status is set to COMPLETED (the team answered) and `focus` is updated to the new `Communication`
  - Every other party (here Team A):
    - if a Task exists: the status is set to REQUESTED and `focus` is updated to the new `Communication` (ensures the subscription fires even when the status was already REQUESTED)
    - if no Task exists, a new one is created with `status` REQUESTED, `intent` ORDER, `basedOn` the `CommunicationRequest`, `for` the `Patient`, `owner` the party (the `CareTeam` for a team, the person otherwise) and `focus` the new `Communication`
- The **OZO platform** (Team A side) receives a notification by Subscription:
  - The new message appears in Team A's shared inbox
  - Any practitioner from Team A can view the response
  - The `Task?status=requested` subscription fires once for Team A: the team's Task moved to REQUESTED and `focus` points to the new `Communication`, which creates a new version even when the status was already REQUESTED.

### Follow-up from a different team member (Team A replies)

A *different* practitioner from Team A follows up on the thread. This demonstrates that any team member can participate in the conversation.

- The **OZO platform** (on behalf of a different Team A practitioner) creates a new `Communication` with the following fields:
  - The `partOf` is set to the reference of the `CommunicationRequest`
  - `inResponseTo` is optional, as above
  - The `sender` is set to the different `Practitioner` from Team A (individual auditability; note this is a different person than the original requester)
  - The `extension[senderCareTeam]` is set to the `CareTeam` of Team A
  - The `payload` consists of text and optionally attachments
  - The `status` is set to COMPLETED
- The **OZO FHIR Api** processes Tasks the same way as described above. The acting team is Team A:
  - Team B's Task becomes REQUESTED with `focus` on the new message
  - Team A's Task becomes COMPLETED with `focus` on the new message (a colleague answered)

### Marking messages as read

When a practitioner reads a message in a team thread:
- The **OZO platform** creates an `AuditEvent` (a read receipt) with the following properties:
  - The `type` is set to `http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle|access`. This is the only type the OZO FHIR Api treats as a read receipt; the REST audit events the proxy creates itself use type `rest` and are ignored here. See [Manu-Read-Team-Thread](AuditEvent-Manu-Read-Team-Thread.html) and [Pieter-Read-Team-Thread](AuditEvent-Pieter-Read-Team-Thread.html) for examples.
  - The `action` is set to 'R'
  - The `recorded` field is set to the current timestamp
  - The `agent.who` field is set to the `Practitioner` who read the message
  - The `agent.extension[careTeam]` is set to the `CareTeam` on whose behalf the message was read (the acting team). Required because the reader is a participant of an organizational team of the thread; the AAA proxy rejects the receipt with 422 when it is missing or names a team that is not a party of the thread or not one of the reader's teams
  - Two `entity` entries, each with one `what` (the profile allows `entity` 0..* and `entity.what` 0..1):
    - A reference to the `CommunicationRequest`. Required: the OZO FHIR Api looks up the team's Task with `Task?based-on=<CommunicationRequest>&owner=<CareTeam>`; without this entry the read receipt is ignored.
    - A reference to the `Communication` that was read. Optional but recommended: the OZO FHIR Api only completes the Task when this is the newest message in the thread, so reading an older message does not clear a newer unread one; without this entry the thread is marked read unconditionally. It also records for the NEN7510 audit trail which message was viewed. At thread creation there is no `Communication` yet; a receipt for the initial message carries the `CommunicationRequest` entity only.
- The **OZO FHIR Api** does the following:
  - The `Task` owned by the `CareTeam` in `agent.extension[careTeam]` is queried and its status is set to COMPLETED
  - No other Task changes. The reader's other teams in the same thread keep their own read state, and a patient care team among the parties keeps its per-member Tasks
- Because the Task belongs to the team, the message is now read for every member of that `CareTeam`. The `AuditEvent` records which person read it.

> **Note:** "Mark as unread" is not part of the OZO messaging model. The read state lives in the `Task` (`requested` = unread, `completed` = read) and only the OZO FHIR Api changes it: on a read receipt, on a new message, and at thread creation. Clients have read-only access to `Task`, and there is no AuditEvent type that sets a Task back to `requested`. A platform that offers "mark as unread" keeps that state locally; it is not visible to other systems or, in team threads, to other team members.
{:.stu-note}

### Interaction diagram

The diagram below displays the team-to-team messaging flow, including thread creation and responses from both teams.
{::nomarkdown}
{% include fhir-team-messaging-interaction.svg %}
{:/}

---

### Example: Pharmacy to Clinic Communication

The following walkthrough shows a concrete example with Apotheek de Pil (Pharmacy A: A.P. Otheeker, Pieter de Vries) and Huisarts Amsterdam (Clinic B: Manu van Weel, Mark Benson, Johan van den Berg). The thread has two Tasks throughout, one per team.

#### Step 1: Pharmacy initiates thread

A pharmacist (A.P. Otheeker) from Apotheek de Pil sends a message to Huisarts Amsterdam about a patient's medication; see [Pharmacy-to-Clinic](CommunicationRequest-Pharmacy-to-Clinic.html) for the full `CommunicationRequest`. `recipient` lists [Clinic-B](CareTeam-Clinic-B.html), the addressed team; `extension[senderCareTeam]` references [Pharmacy-A](CareTeam-Pharmacy-A.html), the initiating team.

The **OZO FHIR Api** creates one `Task` per team:
- [Notify-Clinic-B](Task-Notify-Clinic-B.html): owner Clinic B, status `requested`
- [Notify-Pharmacy-A](Task-Notify-Pharmacy-A.html): owner Pharmacy A, status `completed` (initiating team)

**Notifications fired:**
- `CommunicationRequest` subscription → both teams notified of the new thread (the proxy rewrites the criteria with `participant=`, which matches Pharmacy A through the extension)
- `Task?status=requested` subscription → Clinic B notified of the unread thread, once, through the team's Task

#### Step 2: Manu van Weel reads the message and replies

Dr. Manu van Weel from the clinic reads the message. The **OZO platform** creates a read receipt `AuditEvent` with type `iso-21089-lifecycle|access`, `agent.who` Manu and `agent.extension[careTeam]` Clinic B; see [Manu-Read-Team-Thread](AuditEvent-Manu-Read-Team-Thread.html). There is no `Communication` yet, so the receipt references the `CommunicationRequest` only.

The **OZO FHIR Api** completes the Task of the named team:
- Task (Clinic B): status → `completed` (was: `requested`). The message is now read for Mark Benson and Johan van den Berg as well; the `AuditEvent` records that Manu read it.

Manu then replies with a `Communication` whose `partOf` points to the thread and whose `extension[senderCareTeam]` names Clinic B; see [Clinic-Response-to-Pharmacy](Communication-Clinic-Response-to-Pharmacy.html) for the full resource.

The **OZO FHIR Api** updates both Tasks:
- Task (Pharmacy A): status → `requested`, focus → new `Communication`
- Task (Clinic B): status stays `completed` (acting team), focus → new `Communication`

**Notifications fired:**
- `Communication` subscription → Pharmacy A notified of the new message
- `Task?status=requested` subscription → Pharmacy A notified of the unread message, once

#### Step 3: Different pharmacy practitioner reads and follows up

A.P. Otheeker has not seen the reply yet. Pieter de Vries opens it; the **OZO platform** creates a read receipt with `agent.who` Pieter, `agent.extension[careTeam]` Pharmacy A and two entities, the thread and the `Communication` that was read; see [Pieter-Read-Team-Thread](AuditEvent-Pieter-Read-Team-Thread.html). The `Communication` is the newest message in the thread, so the **OZO FHIR Api** completes the Task:
- Task (Pharmacy A): status → `completed` (was: `requested`). Read for the whole team, including Otheeker.

Pieter then responds, demonstrating that any team member can participate; see [Pharmacy-Followup-by-Pieter](Communication-Pharmacy-Followup-by-Pieter.html) for the full `Communication`. `extension[senderCareTeam]` names Pharmacy A.

The **OZO FHIR Api** updates both Tasks:
- Task (Clinic B): status → `requested` (was: `completed`), focus → new `Communication`
- Task (Pharmacy A): status stays `completed` (acting team), focus → new `Communication`

**Notifications fired:**
- `Communication` subscription → Clinic B notified of new message (always fires)
- `Task?status=requested` subscription → Clinic B notified, once (status changed from COMPLETED to REQUESTED AND focus updated to the new Communication)

> **Note:** Even if Clinic B had not yet read the previous message (Task still REQUESTED), the `focus` update would still create a new Task version and fire the subscription. The `focus` field eliminates the no-op scenario.
{:.stu-note}

Two Tasks per thread instead of five, and no inference of the team at any step.

---

### Query Patterns

`Communication` links to its thread via `partOf`, so thread searches use the `part-of` search parameter. `based-on` is a different element and is not used in the OZO messaging model.

**Find messages for my team (via thread membership):**
```
GET /Communication?part-of:CommunicationRequest.participant=CareTeam/Pharmacy-A
```
The AAA proxy applies this filter automatically for client access, so a plain `GET /Communication` returns the same result for a team member. `participant` matches threads the team is addressed in and threads it initiated. `_include` is blocked for clients by the proxy; system access can add `&_include=Communication:part-of` to fetch the threads in the same call.

**Find all messages in a thread:**
```
GET /Communication?part-of=CommunicationRequest/thread-id&_sort=sent
```

**Find messages I sent:**
```
GET /Communication?sender=Practitioner/my-id
```

**Find messages sent on behalf of my team:**
```
GET /Communication?part-of:CommunicationRequest.participant=CareTeam/Pharmacy-A&sender=Practitioner/a,Practitioner/b
```
There is no search parameter on `Communication.extension[senderCareTeam]`; filter on the team's members or on the extension client-side.

**Find all threads my team takes part in:**
```
GET /CommunicationRequest?participant=CareTeam/Pharmacy-A
```
`participant` is a custom search parameter defined by this IG with a union expression over `recipient` and `extension[senderCareTeam]`; see [ozo-communicationrequest-participant](SearchParameter-ozo-communicationrequest-participant.html).

**Find threads addressed to my team:**
```
GET /CommunicationRequest?recipient=CareTeam/Pharmacy-A
```

**Find threads initiated by my team:**
```
GET /CommunicationRequest?sender-careteam=CareTeam/Pharmacy-A
```
`sender-careteam` is a custom search parameter defined by this IG on `extension[senderCareTeam]`; see [ozo-communicationrequest-sender-careteam](SearchParameter-ozo-communicationrequest-sender-careteam.html). The HAPI FHIR server needs the OZO package installed and existing threads reindexed once for both custom parameters; see [Installing OZO Package in HAPI FHIR Server](hapi-installation.html#custom-search-parameters).

**Shared inbox: unread threads of my team:**
```
GET /Task?owner=CareTeam/Pharmacy-A&status=requested
```
`Task.owner` tells the platform which team inbox a Task belongs to. A practitioner in two teams gets one Task per team for the same thread.

---

### Examples

#### Subscriptions
- [Subscription-Communication](Subscription-Subscription-Communication.html) - New message detection
- [Subscription-Task-Unread](Subscription-Subscription-Task-Unread.html) - Unread message tracking
- [Subscription-CommunicationRequest](Subscription-Subscription-CommunicationRequest.html) - Thread lifecycle

#### Messaging resources
- [Pharmacy-A](CareTeam-Pharmacy-A.html) - Pharmacy team for team-level messaging
- [Clinic-B](CareTeam-Clinic-B.html) - Clinic team for team-level messaging
- [Pharmacy-to-Clinic](CommunicationRequest-Pharmacy-to-Clinic.html) - Team-to-team thread: Clinic B addressed, Pharmacy A initiating
- [Notify-Clinic-B](Task-Notify-Clinic-B.html) - Team Task of Clinic B (owner = CareTeam)
- [Notify-Pharmacy-A](Task-Notify-Pharmacy-A.html) - Team Task of Pharmacy A (initiating team, starts `completed`)
- [Clinic-Response-to-Pharmacy](Communication-Clinic-Response-to-Pharmacy.html) - First reply from clinic, `extension[senderCareTeam]` = Clinic B
- [Pharmacy-Followup-by-Pieter](Communication-Pharmacy-Followup-by-Pieter.html) - Follow-up from different team member, `extension[senderCareTeam]` = Pharmacy A
- [Manu-Read-Team-Thread](AuditEvent-Manu-Read-Team-Thread.html) - Read receipt on behalf of Clinic B (thread entity only)
- [Pieter-Read-Team-Thread](AuditEvent-Pieter-Read-Team-Thread.html) - Read receipt on behalf of Pharmacy A (thread and message entity)

#### Search parameters
- [ozo-communicationrequest-participant](SearchParameter-ozo-communicationrequest-participant.html) - `CommunicationRequest?participant=` finds threads a party takes part in, addressed or initiating
- [ozo-communicationrequest-sender-careteam](SearchParameter-ozo-communicationrequest-sender-careteam.html) - `CommunicationRequest?sender-careteam=` finds threads initiated by a team

For detailed analysis of the addressing solution, see [FHIR Addressing Analysis](fhir-addressing-analysis.html). For the design discussion behind the 0.9.0 model, see [RFC - Team Messaging Model](rfc-team-messaging-model.html).
