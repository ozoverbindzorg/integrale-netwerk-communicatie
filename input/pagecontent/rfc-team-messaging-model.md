### Status

Adopted in IG version 0.9.0, 2026-10-01; compatibility decisions added 2026-10-07. 0.9.0 is a compatibility release that accepts the 0.8.x shape next to the new one; the strict rules apply from the release after 0.9.0. The normative text is on the [Team-to-Team Messaging](interaction-messaging-team.html) and [Individual Messaging](interaction-messaging.html) pages and in the profiles; this page records the proposal, the reasoning and the decisions on the open questions. The implementation steps for the proxy, the HAPI server and connecting platforms are on [AAA Proxy - Changes for 0.9.0](technical-aaa-proxy-0-9-0.html).

#### Decisions on the open questions

| # | Question | Decision in 0.9.0 |
| --- | --- | --- |
| 1 | Name of the union SearchParameter | `participant` (code), id `ozo-communicationrequest-participant`. The `CareTeam.participant` confusion is accepted; `party` is not a term used elsewhere in this IG. |
| 2 | One or two extensions for the acting team | Reuse `OZOSenderCareTeam` (`ozo-sender-careteam`) on `Communication`, with its context widened to `CommunicationRequest` and `Communication`. New `OZOAgentCareTeam` (`ozo-agent-careteam`) on `AuditEvent.agent`. One extension for the two "sender" positions keeps the client code the same; the AuditEvent position is a different role (reader, not sender) and gets its own definition. |
| 3 | Inference transition | Kept for one release, without rejections. In 0.9.0 a missing extension is accepted: the OZO FHIR Api infers the team when exactly one candidate exists and falls back to the 0.8.x behaviour (all candidate teams) with a proxy warning when there are more. Only a present but wrong extension is rejected (422). The inference and the fallback are removed in the release after 0.9.0, when the extension becomes required. |
| 4 | Self-reliant patients as Task owner | `OZOTask.owner` also allows `OZOPatient`. A patient in their own patient care team (allowed since 0.7.8) gets a per-person Task like any other member, which is what the OZO FHIR Api already creates; excluding patients would need a special case in the Task engine. |
| 5 | Order of installation and data migration | Decoupled. The invariant `ozo-cr-sender-careteam-not-in-recipient` is a warning in 0.9.0 and `Task.owner` accepts both shapes, so the 0.9.0 package can be installed under the 0.8.x proxy without behaviour change and without a maintenance window. The proxy then switches scoping, Task mode and extension handling behind configuration flags, and each migration runs at its switch. The strict cut-over (invariant as error, extensions required, per-member mode removed) is the release after 0.9.0; the duplicate clean-up must be complete before that package is installed. |
| 6 | Compatibility with 0.8.x implementations (added 2026-10-07) | 0.9.0 accepts the 0.8.x shape of every affected resource: duplicate recipient (warning), missing acting-team extensions (inferred, with the 0.8.x fallback on ambiguity), per-member Tasks (server mode). A coordinated big-bang rollout across proxy, OZO platform and connecting platforms was judged too risky; the cost is one release in which two shapes coexist and every consumer must treat the thread parties as a set. |

One correction to the proposal below: "On the response side the proxy already accepts a thread when the user is recipient, sender or requester" is true, but it does not cover the other members of the initiating team once that team leaves `recipient`. The proxy's response validation (and its `partOf` thread-membership check on `Communication` writes) must include `extension[senderCareTeam]` among the thread parties. This is in the implementation steps.

---

This RFC answered the review of the 0.8.x team messaging design by the AAA proxy team. It proposed three related changes that together form one breaking release, and records the facts about the proxy and HAPI FHIR that the proposal rests on. The text below is the proposal as reviewed; "current state" refers to 0.8.x.

### The review

The proxy team raised four points:

1. Listing both teams in `CommunicationRequest.recipient` is semantically incorrect. A request has one sending side and one receiving side. The proxy should honour `extension[senderCareTeam]` for organizational teams instead.
2. The read-list logic is inherited from individual messaging: every member gets a Task and the read state is kept per person. In a team thread a message is read as a team, so `Task.owner` should reference the CareTeam.
3. "The sender's team is the recipient team in which the sender is a participant" is ambiguous when the sender is a member of more than one team. The current implementation marks the message read for all of them. The team an action is performed for should be stated explicitly.
4. The subscription criteria `Task?id`, `Communication?id` and `CommunicationRequest?id` are not spec-compliant and only work because HAPI drops parameters without a value.

Point 4 was fixed in 0.8.4 (`Task?`, `Communication?`, `CommunicationRequest?`). Points 1 to 3 are the subject of this RFC.

### Summary of the proposal

| # | Change | Breaking for |
| --- | --- | --- |
| 1 | `CommunicationRequest.recipient` lists the addressed parties only. The initiating team is referenced in `extension[senderCareTeam]` and nowhere else. Access scoping uses a new union SearchParameter that covers both elements. | Clients that create team threads; the proxy query rewrite; HAPI (new SearchParameter plus reindex) |
| 2 | One `Task` per organizational team, with `Task.owner` set to the CareTeam. Patient care teams keep one Task per member. | `OZOTask` profile; the OZO FHIR Api Task engine; the proxy response validation; shared inboxes that query Tasks by owner |
| 3 | Every team-side action names the team it is performed for: `extension[senderCareTeam]` on `Communication`, a new agent extension on the read receipt `AuditEvent`. | Clients that send team messages and read receipts; the proxy content validation and Task engine |

### Change 1: the initiating team leaves `recipient`

#### Current state (0.8.0 to 0.8.4)

`CommunicationRequest.recipient` lists the addressed team and the initiating team; the initiating team is also referenced in `extension[senderCareTeam]`. The invariant `ozo-cr-sender-careteam-in-recipient` enforces the duplicate, and the proxy's `ProfileInjector` adds the team to `recipient` when a client leaves it out.

The reason was never semantic. The AAA proxy scopes every search with a single search parameter whose value is a comma-separated list of the user's own references and all their CareTeams (`recipient=` on `CommunicationRequest`, `part-of:CommunicationRequest.recipient=` on `Communication`, `owner=` on `Task`). FHIR search combines different parameters with AND. An OR across `recipient` and `sender-careteam` is only possible with `_filter`, which the proxy blocks for clients. Without the duplicate entry the members of the initiating team could not find the thread they started.

On the response side the proxy already accepts a thread when the user is recipient, sender or requester. The gap was on the search side only.

#### Proposal

- `CommunicationRequest.recipient` contains the addressed parties only: the addressed team(s), or individual practitioners and related persons, or a patient care team. The initiating team is referenced in `extension[senderCareTeam]` and must not appear in `recipient`. The invariant `ozo-cr-sender-careteam-in-recipient` is replaced by `ozo-cr-sender-careteam-not-in-recipient`.
- A new SearchParameter `ozo-communicationrequest-participant` (code `participant`, type `reference`, targets `CareTeam`, `Practitioner`, `RelatedPerson`, `Patient`) with a union expression:

  ```
  CommunicationRequest.recipient
    | CommunicationRequest.extension('http://ozoverbindzorg.nl/fhir/StructureDefinition/ozo-sender-careteam').value.ofType(Reference)
  ```

  Union expressions are standard FHIR: the base R4 registry defines `Observation.combo-code` as `Observation.code | Observation.component.code`. HAPI indexes every path of the union under the one parameter, so a single `participant=CareTeam/Pharmacy-A` matches threads where Pharmacy A is addressed or initiating. The existing `sender-careteam` parameter stays for "threads my team initiated".
- The AAA proxy scopes `CommunicationRequest` with `participant=` and `Communication` with `part-of:CommunicationRequest.participant=`. Subscription criteria are rewritten by the same rules, so no separate change is needed there. The `ProfileInjector` no longer adds the initiating team to `recipient`. The existing `senderCareTeam` validation (team readable, no `subject`, requester is a participant) stays.
- The OZO FHIR Api Task engine treats the set of thread parties as `recipient` plus `extension[senderCareTeam]` in every path: thread creation (already the case), new `Communication` and read receipt (currently `recipient` only).
- HAPI: install the SearchParameter with the 0.9.0 package and reindex `CommunicationRequest` once, as was done for `sender-careteam` in 0.8.0. Chained search on a custom parameter (`part-of:CommunicationRequest.participant`) must be verified on the deployed HAPI version (8.8) before release.

#### Migration

Threads created under 0.8.x keep both entries in `recipient`. They remain findable, because the union parameter matches either element. They violate the new invariant only on their next update (HAPI validates on write, not on read). Recommended: a one-off clean-up by the system user that removes the duplicate `recipient` entry from existing team threads, so that later status updates do not fail validation. The number of team threads is small; team messaging has been in use since 0.6.0 only.

### Change 2: one Task per organizational team

#### Current state

The OZO FHIR Api creates one `Task` per member of every recipient CareTeam, with `Task.owner` set to the individual. In a team thread the Tasks of all members of the sender's or reader's team are patched together (team-wide read, 0.8.0), so they always carry the same status. A new team member only gets a Task when the CareTeam change is processed. `OZOTask.owner` is restricted to `OZOPractitioner` and `OZORelatedPerson`, although the engine sets `owner` to whatever `participant.member` references.

The proxy already includes the user's CareTeam references when it scopes `Task` searches and subscription criteria (`owner=Practitioner/x,CareTeam/y`). Its response validation, however, only accepts the practitioner as `owner`, so a CareTeam-owned Task in a result would fail the whole search with 403. That check has to change together with this proposal.

#### Proposal

- `OZOTask.owner` allows `Reference(OZOPractitioner or OZORelatedPerson or OZOOrganizationalCareTeam)`. FHIR R4 `Task.owner` already permits `CareTeam`.
- The OZO FHIR Api creates Tasks per thread party:

  | Party in `recipient` or `extension[senderCareTeam]` | Tasks |
  | --- | --- |
  | Organizational CareTeam (no `subject`) | One Task, `owner` = the CareTeam |
  | Patient care team (with `subject`) | One Task per member, as today |
  | Individual practitioner or related person | One Task for that person, as today |

- Status rules stay the same, now applied to the team Task: at thread creation the initiating team's Task starts `completed` and every other Task `requested`; on a new `Communication` the acting team's Task becomes `completed` and every other Task `requested`, all with `focus` set to the new message; on a read receipt the acting team's Task becomes `completed` when the `Communication` entity is the newest message in the thread. "Acting team" is defined in change 3.
- Membership changes of an organizational team need no Task handling: a new member sees the team's Task immediately, a removed member loses access through the proxy scoping.
- Who in a team has personally seen a message stays visible in the read receipt `AuditEvent` resources, which is what NEN7510 asks for. The Task is the inbox state of the team, not of the person.
- Subscriptions: `Task?status=requested` is unchanged and keeps covering team Tasks, because the proxy already adds the CareTeam references to the criteria. A platform receives one notification per team Task change instead of one per member.
- Shared inbox: `Task.owner` tells the platform which team inbox a Task belongs to. A practitioner in two teams sees two Tasks for the same thread, one per team, each with its own read state.

#### Migration

Existing per-member Tasks in team threads are replaced by a one-off job run by the system user: for each team thread and organizational team, create the team Task with `status` `completed` when all member Tasks are `completed` and `requested` otherwise, and `focus` copied from the member Tasks. The member Tasks are set to `cancelled` as described on the [Resource Lifecycle](resource-lifecycle.html) page; nothing is deleted. Patient care team Tasks are untouched.

### Change 3: name the team an action is performed for

#### Current state

The OZO FHIR Api infers the sender's or reader's team as "every organizational recipient team that lists the person as a participant". When the person is a participant of two organizational teams in the same thread, both teams are marked read. The proxy repository lists this as an open item; no test covers it. At thread creation the team is explicit (`extension[senderCareTeam]`), but the engine uses it only as one more candidate.

#### Proposal

- `OZOCommunication` gains `extension[senderCareTeam]` (0..1, the existing `OZOSenderCareTeam` extension, `Reference(OZOOrganizationalCareTeam)`): the team on whose behalf the message is sent. It is required when `Communication.sender` is a participant of at least one organizational team of the thread, and it must reference one of those teams. The AAA proxy validates this the way it validates `senderCareTeam` on `CommunicationRequest` and rejects the message with 422 otherwise.
- `OZOAuditEvent` gains an extension on `agent`, proposed id `ozo-agent-careteam` (`Reference(OZOOrganizationalCareTeam)`): the team on whose behalf the agent acted. The read receipt carries it under the same rule as the `Communication` extension. FHIR R4 `AuditEvent.agent.who` does not allow `CareTeam` (R5 does), and `entity` describes what was accessed rather than who acted, so an extension is the honest place.
- The OZO FHIR Api uses the named team only. The sender's other teams are treated like any other party: their Task becomes `requested` on a new message and stays as it is on a read receipt.
- `CommunicationRequest` is already explicit and does not change.

#### Transition

For one release the OZO FHIR Api may infer the team when the extension is absent and exactly one candidate team exists; this keeps the current OZO platform client working. When more than one candidate exists and the extension is absent, the request is rejected with 422 instead of marking every team read. The inference is removed in the release after 0.9.0.

### Worked example

Pharmacy A (A.P. Otheeker, Pieter de Vries) writes to Clinic B (Manu van Weel, Mark Benson, Johan van den Berg) about patient H. de Boer. Both are organizational teams.

| Step | Resource | Task (owner Clinic-B) | Task (owner Pharmacy-A) |
| --- | --- | --- | --- |
| 1. Otheeker creates the thread. `recipient` = Clinic-B, `extension[senderCareTeam]` = Pharmacy-A | `CommunicationRequest` | `requested` | `completed` |
| 2. Manu reads it. Read receipt with `agent.who` = Manu, agent extension = Clinic-B | `AuditEvent` | `completed` | `completed` |
| 3. Manu replies. `extension[senderCareTeam]` = Clinic-B | `Communication` | `completed`, focus = reply | `requested`, focus = reply |
| 4. Pieter reads and follows up. Read receipt and `Communication`, both naming Pharmacy-A | `AuditEvent`, `Communication` | `requested`, focus = follow-up | `completed`, focus = follow-up |

Two Tasks per thread instead of five, and no inference of the team at any step.

### Impact summary

| Component | Change 1 | Change 2 | Change 3 |
| --- | --- | --- | --- |
| IG profiles and conformance resources | Invariant inverted; new `participant` SearchParameter | `OZOTask.owner` adds `OZOOrganizationalCareTeam` | `OZOCommunication` extension slot; `OZOAuditEvent` agent extension |
| IG examples and pages | `Pharmacy-to-Clinic` loses the duplicate recipient; Team-to-Team Messaging page | Team Task examples replace the per-member Tasks in the team walkthrough | Examples carry the extensions; both messaging pages |
| AAA proxy, query rewrite | `participant=` and `part-of:CommunicationRequest.participant=`; `ProfileInjector` stops adding the team | None | None |
| AAA proxy, content and response validation | None | Accept the user's organizational teams as `Task.owner` | Validate the extension on `Communication` and `AuditEvent` |
| OZO FHIR Api (ReadListService) | Parties = `recipient` plus `extension[senderCareTeam]` in every path | Team Task per organizational team; lookup by `based-on` and `owner=CareTeam/x` | Use the named team; 422 on ambiguity |
| HAPI FHIR server | Install SearchParameter, reindex `CommunicationRequest` | None | None |
| OZO platform and connecting platforms | Stop adding the own team to `recipient` | Inbox by `Task.owner`; one Task per team | Send the extension on messages and read receipts |
| Data migration | Optional clean-up of duplicate recipients | Recompute Tasks for team threads | None |

### Open questions

1. Name of the union SearchParameter: `participant` (used here) or `party`. `participant` reads well in `part-of:CommunicationRequest.participant` but can be confused with `CareTeam.participant`.
2. One extension definition for "acting team" on both `Communication` and `AuditEvent.agent` (for example `ozo-acting-careteam`), or reuse `OZOSenderCareTeam` on `Communication` and add `ozo-agent-careteam` for `AuditEvent`, as proposed here.
3. Keep the inference transition for one release, or require the extensions from 0.9.0 on and update the OZO platform client in the same deployment.
4. Self-reliant patients participate in a patient care team as `Patient` since 0.7.8. The engine then creates a Task with `owner` = `Patient`, which `OZOTask` does not allow. Decide whether 0.9.0 adds `OZOPatient` to `Task.owner` or excludes patients from Task creation.
5. Whether the one-off migrations (duplicate recipient clean-up, Task recomputation) run before or after the 0.9.0 package is installed. Installing first makes existing threads non-updatable until cleaned; cleaning first requires the system user to write resources that the 0.8.x package still accepts.

### Versioning

The three changes alter the `CommunicationRequest`, `Task`, `Communication` and `AuditEvent` contracts and require coordinated proxy and client changes, so they ship together as 0.9.0 (pre-1.0, a MINOR bump is the breaking bump). The subscription criteria fix (point 4 of the review) is independent and shipped as 0.8.4.
