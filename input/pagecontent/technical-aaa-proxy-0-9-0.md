This page is the implementation guide for the AAA proxy team for IG version 0.9.0. It lists, per proxy component, what has to change to implement the revised team messaging model, which behaviours stay switchable so that 0.8.x clients keep working, in which order the HAPI server, the proxy and the data migrations are rolled out, and how to verify the result. The design and its rationale are on [RFC - Team Messaging Model](rfc-team-messaging-model.html); the normative behaviour is on [Team-to-Team Messaging](interaction-messaging-team.html). The general description of the proxy is on [AAA Proxy](technical-aaa-proxy.html).

0.9.0 is a compatibility release. The profiles accept both the 0.8.x and the 0.9.0 shape of every affected resource, and the proxy moves from the old to the new behaviour per environment behind three configuration flags. The strict cut-over (invariant as error, acting-team extensions required, per-member Tasks for organizational teams gone) is the release after 0.9.0.

Class and method names below refer to the `aaa-proxy-reactive` repository at the state that implements fhir.ozo 0.8.x (release 0.3.0). Line numbers are indicative. Configuration property names marked *proposed* are suggestions; the proxy team picks the final names.

### What changes in the contract

| # | 0.8.x | 0.9.0 | Release after 0.9.0 | Profile / resource |
| --- | --- | --- | --- | --- |
| 1 | The initiating team is in `extension[senderCareTeam]` **and** in `recipient` (invariant `ozo-cr-sender-careteam-in-recipient`, error). | The initiating team is in `extension[senderCareTeam]`; repeating it in `recipient` is deprecated (invariant `ozo-cr-sender-careteam-not-in-recipient`, **warning**) and has no effect. A new union SearchParameter `participant` matches `recipient` and the extension. | The invariant becomes an error. | [OZOCommunicationRequest](StructureDefinition-ozo-communicationrequest.html), [ozo-communicationrequest-participant](SearchParameter-ozo-communicationrequest-participant.html) |
| 2 | One `Task` per member of every recipient CareTeam; `Task.owner` is a person. | `OZOTask.owner` also allows `OZOOrganizationalCareTeam` and `OZOPatient`. The Task engine has two modes: per member (0.8.x) and one Task per organizational team (`owner` = the `CareTeam`). | The per-member mode for organizational teams is removed. | [OZOTask](StructureDefinition-ozo-task.html) |
| 3 | The team a message or read receipt is for is inferred from the person's memberships; a member of two teams marks both. | `Communication.extension[senderCareTeam]` and `AuditEvent.agent.extension[careTeam]` name the team. When present they are validated (422 when wrong). When absent, the team is inferred as in 0.8.x. | The extensions are required when the person is in an organizational team of the thread. | [OZOCommunication](StructureDefinition-ozo-communication.html), [OZOAuditEvent](StructureDefinition-ozo-auditevent.html), [ozo-agent-careteam](StructureDefinition-ozo-agent-careteam.html) |

Two terms used throughout:

- **Thread parties**: the set union of `CommunicationRequest.recipient` and the CareTeam in `CommunicationRequest.extension[senderCareTeam]`. Every rule that today reads "recipient" (scoping, response validation, Task creation, read scope) must read "thread parties". Because it is a set, the deprecated duplicate entry changes nothing.
- **Acting team**: the organizational CareTeam named in `Communication.extension[senderCareTeam]` or `AuditEvent.agent.extension[careTeam]`. The **candidate teams** for a person are the organizational thread parties (no `subject`) that list the person as a direct participant. When the extension is absent, the acting team is the single candidate, or (0.9.0 fallback) all candidates.

### Compatibility flags

| Flag (*proposed*) | `false` (0.8.x behaviour) | `true` (0.9.0 behaviour) | When to switch |
| --- | --- | --- | --- |
| `ozo.team-messaging.participant-scoping` | Scope `CommunicationRequest` on `recipient=` and `Communication` on `part-of:CommunicationRequest.recipient=`; the `ProfileInjector` adds the `extension[senderCareTeam]` team to `recipient` (today's `inject-sender-careteam-recipient`). | Scope on `participant=` and `part-of:CommunicationRequest.participant=`; the injector leaves `recipient` alone. | After the 0.9.0 package is installed and the `CommunicationRequest` reindex has finished. Run migration M3 at the switch; M1 only after it. |
| `ozo.team-messaging.team-tasks` | The `ReadListService` creates one Task per member of an organizational team and fans reads out to the team's members (team-wide read). | One Task per organizational team, `owner` = the CareTeam. | Together with migration M2, per environment, when the clients of that environment accept a CareTeam as `Task.owner`. |
| `ozo.team-messaging.infer-acting-team` | n/a | `true` (0.9.0 default): a missing extension is accepted; one candidate team is inferred, two or more fall back to all candidates with a WARN log. `false` (behaviour of the next release): a missing extension is rejected with 422 when candidate teams exist. | Set to `false` in the release after 0.9.0. |

The two scoping behaviours and the injector must flip together, which is why they share one flag: with `participant` scoping and the injector still on, every new thread keeps the deprecated duplicate; with `recipient` scoping and the injector off, the members of an initiating team cannot find a clean-shape thread. The Task-owner change in response validation and the thread-party change in `getPeopleInMessage` (sections 3 and 4) are not behind a flag; they are correct in both modes.

Ship the proxy with `participant-scoping=false`, `team-tasks=false`, `infer-acting-team=true`. Deploying it is then a no-op for clients.

### Order of operations

1. **HAPI**: pin `fhir.ozo` 0.9.0 (`hapi.application.yaml` in the proxy repository, currently 0.8.2, and the production configuration in the gitops repository), restart HAPI, run `$reindex` on `CommunicationRequest?` and wait for the job to finish. Under the 0.8.x proxy the package changes nothing: the injector keeps adding the duplicate, which the warning-severity invariant tolerates; per-member Tasks still validate; the extensions are optional. See [HAPI installation](hapi-installation.html#custom-search-parameters).
2. **Verify on the deployed HAPI version (8.8)**: the direct form `CommunicationRequest?participant=CareTeam/<id>` and the chained form `Communication?part-of:CommunicationRequest.participant=CareTeam/<id>` return the same threads as `recipient=` plus `sender-careteam=`; the chained form works inside a Subscription criteria; a `CommunicationRequest` with the duplicate recipient is accepted on write (HAPI's `RequireValidationRule` rejects on error and fatal only, so a warning-severity invariant passes; confirm on staging).
3. **Proxy**: deploy the version that implements this page, with the compatibility defaults.
4. **Scoping**: set `participant-scoping=true`; run migration M3 (stored Subscription criteria). From now on migration M1 (duplicate recipients) may run at any time before the next release.
5. **Team Tasks**: per environment, when its clients handle a CareTeam as `Task.owner`: set `team-tasks=true` and run migration M2 in the same change.
6. **Clients**: the OZO platform and connecting platforms adopt the clean shape and the extensions within the lifetime of 0.9.0. Nothing breaks for them before step 5, and step 5 only changes what `Task.owner` contains.
7. **Release after 0.9.0**: invariant to error, `infer-acting-team=false`, per-member mode removed. M1 must be complete before that package is installed, because threads with the duplicate become non-updatable then.

### HAPI FHIR server

- Install the 0.9.0 minimal package. The package installer replaces the StructureDefinitions by canonical URL and adds the new SearchParameter and the new extension definition.
- `supported_resource_types` already lists `SearchParameter`; nothing changes there.
- Reindex once:

```bash
curl -X POST http://hapi:8080/fhir/\$reindex \
  -H "Content-Type: application/fhir+json" \
  -d '{"resourceType":"Parameters","parameter":[{"name":"url","valueString":"CommunicationRequest?"}]}'
```

- Until the job has finished, `participant=` returns only threads written after the installation. Do not switch `participant-scoping` before the job is done.
- The union expression indexes both paths under one parameter. For a thread that lists the initiating team in `recipient` and in the extension, the team is indexed twice; HAPI de-duplicates the search result.

### Proxy changes per component

#### 1. Query rewrite (`applyAccessRules`)

Files: `validator/PractitionerAccessValidator.java` (L170-233), `validator/RelatedPersonAccessValidator.java` (L138-195), `validator/PatientAccessValidator.java` (L138-199).

| Resource | `participant-scoping=false` (today) | `participant-scoping=true` |
| --- | --- | --- |
| `CommunicationRequest` | `recipient=<self,careTeams>` | `participant=<self,careTeams>` |
| `Communication` | `part-of:CommunicationRequest.recipient=<self,careTeams>` | `part-of:CommunicationRequest.participant=<self,careTeams>` |
| `Task` | `owner=<self,careTeams>` (Practitioner), `owner=<self>` (RelatedPerson), `patient=<self>` (Patient) | Unchanged. The Practitioner value already contains the user's CareTeams (`getPractitionerAndCareTeams`, L359-364), which is what makes team Tasks visible in the team-Task mode. |
| `AuditEvent` | `agent=<self, flattened team practitioners>` | Unchanged. `agent.extension[careTeam]` is not a search parameter. |

- The value list is built by `PractitionerService.getPractitionerReferences` plus `CareTeamService.getCareTeamReferences` (direct participation, patient and organizational teams alike). Nothing changes there.
- `processSubscriptionContent` (`AbstractAccessValidator`, L485-513) applies the same rules to Subscription criteria at create time, so new subscriptions follow the flag automatically. Existing subscriptions keep their rewritten criteria; see migration M3.
- `rejectBlockedSearchParameters` (L254-297) needs no change: a client-supplied `participant` or `part-of:CommunicationRequest.participant` is overwritten by `replaceQueryParam`, as `recipient` is today.
- Tests: `validator/PractitionerAccessValidatorQueryRewriteTest.java`, `ProxyRouterCredentialTest.java` (criteria rewrite, L177-210); run both with the flag in each position.

#### 2. ProfileInjector

File: `filter/ProfileInjector.java`.

- `ensureSenderCareTeamIsRecipient` (L145-156) stays. It runs when `participant-scoping=false` and is skipped when `true`; the separate property `ozo.profile-injection.inject-sender-careteam-recipient` (L66) is removed in favour of the shared flag.
- Never strip and never reject a duplicate that a client sends: the invariant is a warning, HAPI accepts the write, and the duplicate has no effect. With `participant-scoping=true`, log a duplicate at WARN with the calling application and the opaque user reference (no names, no patient data) so that the remaining 0.8.x clients can be found before the next release.
- The injector runs for every caller type before the validators (`router/ProxyRouter.java`, `modifyRequestBody`, L310-318); unchanged.
- Test: `filter/ProfileInjectorTest.java` (the `senderCareTeam` tests at L45-99 become flag-dependent).

#### 3. Content validation (`applyAccessRulesToContent`)

File: `validator/PractitionerAccessValidator.java` (L244-298) unless noted.

**Thread parties helper (not behind a flag).** `AbstractAccessValidator.getPeopleInMessage(CommunicationRequest)` (L164-175) returns recipient, sender and requester. Add the reference in `extension[senderCareTeam]` (`FhirUtils.getSenderCareTeam`, `fhir/FhirUtils.java` L32-38) and de-duplicate. This single change fixes the write-side `checkThreadMembership` (L331-356) and the response validation of threads (section 4) for members of the initiating team who are neither requester nor sender; without it they get 403 on a clean-shape thread. It is harmless while the duplicate is still present.

**Acting-team helper (shared with the `ReadListService`).** One method, for example in `FhirUtils` or a small `ActingTeamResolver`, takes the thread, the loaded CareTeam parties, the person's references and the optional named team, and returns one of: `NAMED(team)`, `INFERRED(team)`, `FALLBACK(teams)`, `NONE`, or an error (named team not a candidate). The validators and the engine must agree on the candidate rule, so do not implement it twice.

**CommunicationRequest** (L272-287):

- Keep `checkSenderCareTeam` (L305-322): team readable, no `subject`, user is a direct participant.
- No check on the duplicate. HAPI validates the invariant and reports a warning.

**Communication** (L256-271), new check after `checkThreadMembership`:

1. Resolve the thread (already read in `checkThreadMembership`) and its CareTeam parties: recipient CareTeams plus the extension team, de-duplicated. Read each team (`genericFhirClient.getResource`, unscoped, fail closed as `checkSenderCareTeam` does).
2. Candidate teams = parties without `subject` that list the sender as a direct participant.
3. `extension[senderCareTeam]` present: it must be one of the candidate teams, else 422 ("senderCareTeam is not a party of this thread" or "sender is not a member of senderCareTeam").
4. Absent, no candidates: accept. The sender acts as an individual (addressed individually or through a patient care team).
5. Absent, one candidate: accept; the engine infers the team.
6. Absent, two or more candidates: with `infer-acting-team=true` accept and log at WARN with the calling application and the opaque user reference (the engine falls back to all candidates, as 0.8.x did); with `infer-acting-team=false` reject with 422 ("senderCareTeam is required: sender is a participant of more than one team in this thread").

**AuditEvent** (L288-293): keep `validateAuditEventAgents` (`AbstractAccessValidator` L140-158). Apply the same six steps to `agent.extension[careTeam]` of the agent with `requestor = true`, only for read receipts: `type` = `iso-21089-lifecycle|access` with a `CommunicationRequest` entity. Other AuditEvent types are not inspected.

**RelatedPerson and Patient validators** (`RelatedPersonAccessValidator` L314-361, `PatientAccessValidator` L318-365): related persons and patients are never participants of an organizational team, so `extension[senderCareTeam]` on their messages and `agent.extension[careTeam]` on their receipts must be absent; reject with 422 when present. No other change.

Tests: `validator/PractitionerAccessValidatorWritePathTest.java`, `validator/PractitionerAccessValidatorAuditEventTest.java`, `validator/AuditEventAgentCheckTest.java`. New cases: extension present and valid; present but not a party; present but sender not a member; absent with one candidate (accepted); absent with two candidates and inference on (accepted, WARN logged); absent with two candidates and inference off (422); absent with no candidates (accepted); extension on a RelatedPerson message (422).

#### 4. Response validation (`analyseResource`), not behind a flag

| Validator | Resource | Today | 0.9.0 |
| --- | --- | --- | --- |
| Practitioner (L112-118) | `Task` | `owner` must be one of the user's Practitioner references | `owner` must be one of the user's Practitioner references **or** one of the user's CareTeam references (`careTeamService.getCareTeamsForCurrentUser`, already loaded at L51-168). In the per-member mode no CareTeam-owned Task exists, so the wider check changes nothing there; in the team-Task mode every search that returns a team Task would otherwise fail with 403. |
| Practitioner (L119-128), RelatedPerson (L262-271), Patient (L266-275) | `CommunicationRequest` | user or CareTeam in `getPeopleInMessage` (recipient, sender, requester) | Same check; covered by the `getPeopleInMessage` change in section 3. |
| Practitioner (L129-154), RelatedPerson (L272-294), Patient (L276-298) | `Communication` | user or CareTeam in the `partOf` thread's **recipient** | user or CareTeam in the `partOf` thread's **parties** (recipient plus extension team). Reuse `getPeopleInMessage` or add the extension explicitly. |
| RelatedPerson (L255-261), Patient (L259-265) | `Task` | owner is the RelatedPerson; `for` is the Patient | Unchanged. |

Tests: `ProxyRouterPractitionerAccessTest.java`, `ProxyRouterRelatedPersonAccessTest.java`, `ProxyRouterPatientAccessTest.java`. New cases: a Pharmacy A member who is not the requester reads a clean-shape `Pharmacy-to-Clinic` (200), its messages (200) and, in the team-Task mode, its team Task (200); a practitioner outside both teams gets nothing (empty Bundle, no 403).

#### 5. ReadListService (Task engine)

File: `service/ReadListService.java`. The engine runs asynchronously on Redis events (`service/MessageSubscriber.java` L104-153) after HAPI has accepted the write. It can therefore never reject a request; all 422 rules live in the validators (section 3). The engine assumes a validated resource.

**Shared helpers (both modes).**

- *Thread parties*: a helper that returns the de-duplicated party references of a `CommunicationRequest`: every `recipient.reference` plus the extension team reference. Use it everywhere `getRecipient()` is used today: `handleNewCommunicationRequest` (L75-94), `readRecipientCareTeams` (L101-113), `readScopeOf` (L210-240), `handleMessageDeleted` (L403-475) and `handleCareTeamChange` (L260-279). Today `readScopeOf` only looks at recipient teams and `initiatingTeamMembers` (L133-155) reads the extension team as an extra candidate; both become the same party set.
- *Acting team*: the resolver from section 3. For a `Communication` the person is `sender` and the named team is `extension[senderCareTeam]`; for a read receipt the person is the requestor `agent.who` and the named team is `agent.extension[careTeam]`.
- *Initial status at thread creation*: the sender (falling back to `requester` when `sender` is absent; `sender` is 0..1 in the profile and `initiatingTeamMembers` is keyed on it today) and the extension team are the acting parties; their Tasks start `completed`, all others `requested`.
- `markTasksAsUnread` (L660-725) must skip Tasks with status `cancelled` or `entered-in-error`. Today it patches every Task found by `based-on`, which would resurrect the member Tasks that migration M2 cancels.
- `handleMessageRead` (L293-373) builds the entity map with `Collectors.toMap` keyed on entity type (L307-309) and throws on two entities of the same type. Make it tolerant while touching this method.

**Per-member mode (`team-tasks=false`).** The existing engine with two behavioural changes:

1. The team-wide fan-out (`organisationalTeamMembersOf`, L161-176) is restricted to the acting team(s) from the resolver: the named team, the single inferred team, or (fallback) all candidate teams, which is today's behaviour. A client that already sends the extension therefore gets the two-teams bug fixed in this mode as well.
2. `handleCareTeamChange` searches threads with `participant=CareTeam/<id>` when `participant-scoping=true` and with `recipient=CareTeam/<id>` otherwise (the injector guarantees the duplicate while scoping is off). Backfill for new members stays as it is.

**Team-Task mode (`team-tasks=true`).** Replace `createTaskForParticipantsIfNoneExist(cr, careTeam, completed)` (L556-561) with a dispatch on the party type:

| Party | Task |
| --- | --- |
| CareTeam without `subject` (organizational) | one Task, `owner` = `CareTeam/<id>`, `ifNoneExist` = `Task?based-on=CommunicationRequest/<id>&owner=CareTeam/<id>` |
| CareTeam with `subject` (patient care team) | one Task per direct participant, as today (L573-604). A nested organizational CareTeam among the participants gets one team Task, not a Task per member. |
| Practitioner, RelatedPerson, Patient | one Task for that person, as today |

`for` is `cr.getSubject()` in all cases.

- *New Communication* (`handleNewCommunication`, L185-199): acting parties = the sender reference plus the acting team(s) from the resolver (named, inferred, or all candidates under the fallback). `markTasksAsUnread(tasks, actingParties, "Communication/<id>")`: `completed` for Tasks whose `owner` is in the list, `requested` for the rest, `focus` set on all. Owner comparison on reference strings works for `CareTeam/<id>` as it does for `Practitioner/<id>`. No member fan-out.
- *Read receipt* (`handleMessageRead`): keep the type check, the required `CommunicationRequest` entity and the newest-message check on the optional `Communication` entity (`getNewestCommunication`, L525-542). Then one conditional patch per acting party, `Task?based-on=CommunicationRequest/<id>&owner=<party>` with `replace /status completed` (L344-359): the named or inferred team, all candidate teams under the fallback, or the `agent.who` reference itself when the person is in no organizational team of the thread.
- *Communication deleted* (`handleMessageDeleted`): readers of the new latest message are derived from read receipt AuditEvents and the latest sender. Resolve the acting party of each receipt (agent extension, fallback `agent.who`) and of the latest message (sender extension, fallback `sender`) with the same resolver, then `markTasksAsUnread` with that list.
- *CareTeam change* (`handleCareTeamChange`): organizational team (no `subject`): return without creating Tasks. The team's Task is shared; a new member sees it through the proxy scoping, a removed member loses access the same way. Patient care team: unchanged. The existing `TODO` about PATCH membership changes (L260) is unrelated to 0.9.0.

Tests: `service/ReadListServiceTest.java`, `service/ReadListServiceTeamMessagingTest.java` (`organisationalTeamChange_backfillsTasksForNewMembers` stays valid for the per-member mode and must be skipped or inverted for the team-Task mode), `service/MessageSubscriberRetractionTest.java`. New cases follow the worked example on the team messaging page in the team-Task mode: two Tasks after creation (owner Clinic-B `requested`, owner Pharmacy-A `completed`); reply with extension Clinic-B flips both; read receipt with agent extension Pharmacy-A completes one Task and touches nothing else; a sender in two teams with the extension completes the named team only; the same sender without the extension completes both (fallback); absent extension with one candidate infers; cancelled Tasks are not patched; patient care team threads behave as before. In the per-member mode: the 0.8.x cases plus "extension present restricts the fan-out to the named team".

#### 6. Configuration

| Property | 0.8.x | 0.9.0 | Release after 0.9.0 |
| --- | --- | --- | --- |
| `ozo.profile-injection.inject-sender-careteam-recipient` | `true` | Removed; folded into `participant-scoping` | n/a |
| `ozo.team-messaging.participant-scoping` (*proposed*) | n/a | `false` at deployment; `true` after the reindex and M3 | `true`, flag removed |
| `ozo.team-messaging.team-tasks` (*proposed*) | n/a | `false` at deployment; `true` per environment with M2 | `true`, flag removed |
| `ozo.team-messaging.infer-acting-team` (*proposed*) | n/a | `true` | `false`, then removed |

Document the final names on the [AAA Proxy](technical-aaa-proxy.html) configuration reference in the IG release that follows.

### Data migration (system user)

The system user is not scoped and may PATCH (`SystemAccessValidator` rejects DELETE only). Nothing is deleted; see [Resource Lifecycle](resource-lifecycle.html). Each migration is tied to a flag switch.

**M3. Stored Subscription criteria, at the `participant-scoping` switch.** Subscription criteria are rewritten once at create time (snapshot) and the owner is stamped as `meta.tag`. Existing `CommunicationRequest` and `Communication` subscriptions therefore carry `recipient=` and `part-of:CommunicationRequest.recipient=`. They keep firing for addressed threads but miss clean-shape threads in which the subscriber's team is only the initiating team. Rewrite them in place (`PUT` with `recipient=` replaced by `participant=` in `criteria`, keeping the owner tag) or ask the platforms to recreate them. `Task` subscriptions are not affected.

**M1. Duplicate recipients, only after the `participant-scoping` switch and before the release after 0.9.0.** Never run this while the proxy still scopes on `recipient=`: a cleaned thread would disappear for the members of its initiating team. For every team thread, remove the initiating team from `recipient`.

```
GET /CommunicationRequest?sender-careteam:missing=false&_count=100
```

For each thread whose `recipient` contains the reference in `extension[senderCareTeam]`, send a FHIRPath patch:

```json
{
  "resourceType": "Parameters",
  "parameter": [{
    "name": "operation",
    "part": [
      {"name": "type", "valueCode": "delete"},
      {"name": "path", "valueString": "CommunicationRequest.recipient.where(reference = 'CareTeam/<team-id>')"}
    ]
  }]
}
```

Threads that are not cleaned stay readable and updatable in 0.9.0 (the invariant is a warning) and become non-updatable once the next package, with the invariant as error, is installed.

**M2. Team Tasks, together with the `team-tasks` switch.** Flip the flag first, then run the migration immediately; the engine skips cancelled Tasks, so a message that arrives in between does no harm. For every team thread and every organizational team party:

1. Read the member Tasks: `Task?based-on=CommunicationRequest/<id>&owner=Practitioner/<a>,Practitioner/<b>,...` for the team's direct participants.
2. Create the team Task with `ifNoneExist` = `Task?based-on=CommunicationRequest/<id>&owner=CareTeam/<team-id>`: `status` = `completed` when every member Task is `completed`, `requested` otherwise (also when a member has no Task); `focus` copied from the member Tasks (they all carry the same value); `intent`, `basedOn`, `for` as usual; `meta.profile` = OZOTask.
3. Set the member Tasks to `status` = `cancelled` (FHIRPath patch `replace Task.status`), so that `Task?status=requested` subscriptions stop matching them. Do this only for members whose Task exists because of the team; a practitioner who is also addressed individually or through a patient care team in the same thread keeps that per-person Task.
4. Patient care team Tasks are not touched.

Use a transaction Bundle per thread so that step 2 and step 3 succeed or fail together. Expect two Tasks per two-team thread afterwards; the team messaging feature has been in use since 0.6.0, so the volume is small. Verify with `Task?based-on=CommunicationRequest/<id>&status:not=cancelled`.

### Connecting platforms (OZO platform and others)

Nothing a 0.8.x client does stops working in 0.9.0. Before the release after 0.9.0, every platform must:

- Stop listing the own team in `CommunicationRequest.recipient`; put it in `extension[senderCareTeam]` only.
- Send `extension[senderCareTeam]` on every `Communication` written for a team, and `agent.extension[careTeam]` on every read receipt written for a team. The rule: required when the user participates in at least one organizational team of the thread; must be one of those teams. Platforms that know the user's teams can decide client-side; the proxy rejects a wrong team with 422.
- Accept a `CareTeam` reference in `Task.owner`. Once an environment runs the team-Task mode, the team's unread threads are `Task?owner=CareTeam/<team>&status=requested`; a user in two teams gets one Task per team for the same thread. The plain `Task?status=requested` subscription keeps working and fires once per team Task change instead of once per member.
- Use the read receipt AuditEvents (`AuditEvent?entity=CommunicationRequest/<id>&type=http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle|access`) when the user interface shows per-person read marks; in the team-Task mode they are no longer visible in Tasks.

### Verification checklist

Run against the e2e stack (`e2e/docker-compose.yaml`, HAPI 8.8 with the 0.9.0 package) with the Pharmacy A / Clinic B fixtures, once per Task mode where the step depends on it:

1. Otheeker (Pharmacy A) creates a thread addressed to Clinic B with the extension and without the duplicate recipient: 201. The same thread with Pharmacy A in `recipient` (0.8.x shape): 201 in both scoping modes; HAPI's validation output shows the warning `ozo-cr-sender-careteam-not-in-recipient`; both teams can read it in both scoping modes.
2. `Task?based-on=<thread>` as the system user returns exactly two Tasks in the team-Task mode (owner Clinic-B `requested`, owner Pharmacy-A `completed`) and five in the per-member mode (as in 0.8.x).
3. With `participant-scoping=true`, Pieter (Pharmacy A, not the requester) reads a clean-shape thread, its messages and `Task?status=requested`: 200, the thread and his Task (personal or team, by mode) are in the results. Before the `getPeopleInMessage` and Task-owner changes this is a 403.
4. Manu (Clinic B) posts a read receipt with `agent.extension[careTeam]` = Clinic-B: in the team-Task mode the Clinic B Task becomes `completed` and the Pharmacy A Task is unchanged; in the per-member mode the three Clinic B member Tasks become `completed`.
5. Manu replies with `extension[senderCareTeam]` = Clinic-B: in the team-Task mode Pharmacy A Task `requested` with `focus` on the reply, Clinic B Task `completed` with the same `focus`; one `Task?status=requested` notification for the Pharmacy A subscription, none for Clinic B.
6. A practitioner who is a participant of both teams replies without the extension: 201, a WARN is logged, and both teams' Tasks are completed (fallback). With the extension naming Clinic-B: only the Clinic B Task (team-Task mode) or the Clinic B member Tasks (per-member mode) are completed. With `infer-acting-team=false` and no extension: 422.
7. Manu replies without the extension while being in exactly one team of the thread: 201, the engine infers Clinic B.
8. A practitioner outside both teams searches `CommunicationRequest` and `Communication`: empty Bundles, no 403.
9. A RelatedPerson posts a `Communication` with `extension[senderCareTeam]`: 422.
10. Chained search `Communication?part-of:CommunicationRequest.participant=CareTeam/Pharmacy-A` as the system user returns the thread's messages for a clean-shape thread; the same with `recipient` returns nothing for Pharmacy A.
11. The 0.8.x e2e suite of proxy release 0.3.0 (`e2e/tests/test_team_messaging.py`, `test_readlist.py`) passes unchanged against the 0.9.0 proxy with the compatibility defaults and the 0.9.0 package. This is the compatibility claim of this release; run it before anything else.
12. Migration dry run on a copy of production data: counts of subscriptions rewritten (M3), threads cleaned (M1), Tasks created and cancelled (M2) match expectations before the real run.
