This page is the implementation guide for the AAA proxy team for IG version 0.9.0. It lists, per proxy component, what has to change to implement the revised team messaging model, in which order the HAPI server, the proxy and the data migrations are rolled out, and how to verify the result. The design and its rationale are on [RFC - Team Messaging Model](rfc-team-messaging-model.html); the normative behaviour is on [Team-to-Team Messaging](interaction-messaging-team.html). The general description of the proxy is on [AAA Proxy](technical-aaa-proxy.html).

Class and method names below refer to the `aaa-proxy-reactive` repository at the state that implements fhir.ozo 0.8.x (release 0.3.0). Line numbers are indicative. Configuration property names marked *proposed* are suggestions; the proxy team picks the final names.

### What changes in the contract

| # | 0.8.x | 0.9.0 | Profile / resource |
| --- | --- | --- | --- |
| 1 | The initiating team is in `extension[senderCareTeam]` **and** in `recipient` (invariant `ozo-cr-sender-careteam-in-recipient`). | The initiating team is in `extension[senderCareTeam]` only (invariant `ozo-cr-sender-careteam-not-in-recipient`). A new union SearchParameter `participant` matches `recipient` and the extension. | [OZOCommunicationRequest](StructureDefinition-ozo-communicationrequest.html), [ozo-communicationrequest-participant](SearchParameter-ozo-communicationrequest-participant.html) |
| 2 | One `Task` per member of every recipient CareTeam; `Task.owner` is a person. | One `Task` per organizational team, `Task.owner` = the `CareTeam`. Patient care teams and individuals keep per-person Tasks. `OZOTask.owner` also allows `OZOPatient`. | [OZOTask](StructureDefinition-ozo-task.html) |
| 3 | The team a message or read receipt is for is inferred from the person's memberships. | `Communication.extension[senderCareTeam]` and `AuditEvent.agent.extension[careTeam]` name the team. Required when the person participates in an organizational team of the thread. | [OZOCommunication](StructureDefinition-ozo-communication.html), [OZOAuditEvent](StructureDefinition-ozo-auditevent.html), [ozo-agent-careteam](StructureDefinition-ozo-agent-careteam.html) |

Two terms used throughout:

- **Thread parties**: `CommunicationRequest.recipient` plus the CareTeam in `CommunicationRequest.extension[senderCareTeam]`. Every rule that today reads "recipient" (scoping, response validation, Task creation, read scope) must read "thread parties".
- **Acting team**: the organizational CareTeam named in `Communication.extension[senderCareTeam]` or `AuditEvent.agent.extension[careTeam]`. The candidate teams for a person are the organizational thread parties (no `subject`) that list the person as a direct participant.

### Order of operations

The package and the proxy must be rolled out together. An old proxy against the new package creates threads that the new invariant rejects (its `ProfileInjector` adds the initiating team to `recipient`); a new proxy against the old package sends `participant=`, which HAPI rejects as an unknown search parameter. Plan one maintenance window:

1. **HAPI**: pin `fhir.ozo` 0.9.0 (`hapi.application.yaml` in the proxy repository, currently 0.8.2, and the production configuration in the gitops repository), restart HAPI, run `$reindex` on `CommunicationRequest?` and wait for the job to finish. See [HAPI installation](hapi-installation.html#custom-search-parameters).
2. **Verify the SearchParameter** on the deployed HAPI version (8.8): direct form `CommunicationRequest?participant=CareTeam/<id>` and chained form `Communication?part-of:CommunicationRequest.participant=CareTeam/<id>` return the same threads as `recipient=` plus `sender-careteam=` did. Also verify that the chained form works inside a Subscription criteria.
3. **Proxy**: deploy the version that implements this page.
4. **Data migration** with the system user, in this order: duplicate recipients (M1), Tasks (M2), stored Subscription criteria (M3). See below.
5. **Clients**: the OZO platform release that sends the extensions and no longer adds its own team to `recipient` goes live in the same window. Connecting platforms are informed through their changelog; the transition rules below keep an unchanged client working for the common case.

Between step 1 and step 4, existing team threads are non-updatable (they still carry the duplicate recipient and HAPI validates on write). Keep that window short.

### HAPI FHIR server

- Install the 0.9.0 minimal package. The package installer replaces the StructureDefinitions by canonical URL and adds the new SearchParameter and the new extension definition.
- `supported_resource_types` already lists `SearchParameter`; nothing changes there.
- Reindex once:

```bash
curl -X POST http://hapi:8080/fhir/\$reindex \
  -H "Content-Type: application/fhir+json" \
  -d '{"resourceType":"Parameters","parameter":[{"name":"url","valueString":"CommunicationRequest?"}]}'
```

- Until the job has finished, `participant=` returns only threads written after the installation. Do not switch the proxy over before the job is done.
- The union expression indexes both paths under one parameter. For a 0.8.x thread that still lists the initiating team in `recipient` and in the extension, the team is indexed twice; HAPI de-duplicates the search result.

### Proxy changes per component

#### 1. Query rewrite (`applyAccessRules`)

Files: `validator/PractitionerAccessValidator.java` (L170-233), `validator/RelatedPersonAccessValidator.java` (L138-195), `validator/PatientAccessValidator.java` (L138-199).

| Resource | Today | 0.9.0 |
| --- | --- | --- |
| `CommunicationRequest` | `recipient=<self,careTeams>` | `participant=<self,careTeams>` |
| `Communication` | `part-of:CommunicationRequest.recipient=<self,careTeams>` | `part-of:CommunicationRequest.participant=<self,careTeams>` |
| `Task` | `owner=<self,careTeams>` (Practitioner), `owner=<self>` (RelatedPerson), `patient=<self>` (Patient) | Unchanged. The Practitioner value already contains the user's CareTeams (`getPractitionerAndCareTeams`, L359-364), which is what makes team Tasks visible. |
| `AuditEvent` | `agent=<self, flattened team practitioners>` | Unchanged. `agent.extension[careTeam]` is not a search parameter. |

- The value list is built by `PractitionerService.getPractitionerReferences` plus `CareTeamService.getCareTeamReferences` (direct participation, patient and organizational teams alike). Nothing changes there: a patient CareTeam in the `owner=` list is harmless, no Task is ever owned by one.
- `processSubscriptionContent` (`AbstractAccessValidator`, L485-513) applies the same rules to Subscription criteria at create time, so new subscriptions follow automatically. Existing subscriptions keep their rewritten criteria; see migration M3.
- `rejectBlockedSearchParameters` (L254-297) needs no change: a client-supplied `participant` or `part-of:CommunicationRequest.participant` is overwritten by `replaceQueryParam`, as `recipient` is today.
- Test: `validator/PractitionerAccessValidatorQueryRewriteTest.java`, `ProxyRouterCredentialTest.java` (criteria rewrite, L177-210).

#### 2. ProfileInjector

File: `filter/ProfileInjector.java`.

- Remove `ensureSenderCareTeamIsRecipient` (L145-156) and the property `ozo.profile-injection.inject-sender-careteam-recipient` (L66). The call in `injectDefaults` (L119-137) goes with it.
- *Proposed* transition aid, one release: when a client still lists the team from `extension[senderCareTeam]` in `recipient`, remove that entry instead of letting HAPI reject the thread with the invariant. Property `ozo.profile-injection.strip-sender-careteam-recipient` (default `true` in the 0.9.0 release, removed in the next). Log at WARN with the calling application and the opaque user reference (no names, no patient data) so the client can be chased. If the proxy team prefers a hard cut, skip this and let the 422 from HAPI stand; the OZO platform client must then be released in the same window.
- The injector runs for every caller type before the validators (`router/ProxyRouter.java`, `modifyRequestBody`, L310-318), so the validators see the cleaned `recipient`.
- Test: `filter/ProfileInjectorTest.java` (the `senderCareTeam` tests at L45-99 assert the old injection and must be inverted).

#### 3. Content validation (`applyAccessRulesToContent`)

File: `validator/PractitionerAccessValidator.java` (L244-298) unless noted.

**Thread parties helper.** `AbstractAccessValidator.getPeopleInMessage(CommunicationRequest)` (L164-175) returns recipient, sender and requester. Add the reference in `extension[senderCareTeam]` (`FhirUtils.getSenderCareTeam`, `fhir/FhirUtils.java` L32-38). This single change fixes the write-side `checkThreadMembership` (L331-356) and the response validation of threads (section 4) for members of the initiating team who are neither requester nor sender; without it they get 403 on their own thread once the team leaves `recipient`.

**CommunicationRequest** (L272-287):

- Keep `checkSenderCareTeam` (L305-322): team readable, no `subject`, user is a direct participant.
- Add: the team in `extension[senderCareTeam]` must not be in `recipient`. HAPI enforces the invariant as well, but the proxy check gives a readable 422 instead of an `OperationOutcome` about `ozo-cr-sender-careteam-not-in-recipient`. Skip the check when the transition strip (section 2) is on, since the injector has already removed the entry.

**Communication** (L256-271), new check after `checkThreadMembership`:

1. Resolve the thread (already read in `checkThreadMembership`) and its CareTeam parties: recipient CareTeams plus the extension team. Read each team (`genericFhirClient.getResource`, unscoped, fail closed as `checkSenderCareTeam` does).
2. Candidate teams = parties without `subject` that list the sender as a direct participant.
3. If `extension[senderCareTeam]` is present: it must be one of the candidate teams, else 422.
4. If it is absent and there is exactly one candidate: accept (transition, 0.9.0 only; log at INFO with the calling application and the opaque user reference, no names or patient data, so the remaining 0.8.x clients can be found). *Proposed* property `ozo.validation.infer-acting-team`, default `true`, removed in the next release.
5. If it is absent and there are two or more candidates: 422, "senderCareTeam is required: sender is a participant of more than one team in this thread".
6. If it is absent and there are no candidates: accept. The sender acts as an individual (addressed individually or through a patient care team).

**AuditEvent** (L288-293): keep `validateAuditEventAgents` (`AbstractAccessValidator` L140-158). Add the same six steps for `agent.extension[careTeam]`, applied only to read receipts: `type` = `iso-21089-lifecycle|access` with a `CommunicationRequest` entity. The agent is `agent.who` of the agent with `requestor = true`. Other AuditEvent types are not inspected.

**RelatedPerson and Patient validators** (`RelatedPersonAccessValidator` L314-361, `PatientAccessValidator` L318-365): related persons and patients are never participants of an organizational team, so `extension[senderCareTeam]` on their messages and `agent.extension[careTeam]` on their receipts must be absent; reject with 422 when present. No other change.

Tests: `validator/PractitionerAccessValidatorWritePathTest.java`, `validator/PractitionerAccessValidatorAuditEventTest.java`, `validator/AuditEventAgentCheckTest.java`. New cases: extension present and valid; present but not a party; present but sender not a member; absent with one candidate (accepted, logged); absent with two candidates (422); absent with no candidates (accepted); extension on a RelatedPerson message (422).

#### 4. Response validation (`analyseResource`)

| Validator | Resource | Today | 0.9.0 |
| --- | --- | --- | --- |
| Practitioner (L112-118) | `Task` | `owner` must be one of the user's Practitioner references | `owner` must be one of the user's Practitioner references **or** one of the user's CareTeam references (`careTeamService.getCareTeamsForCurrentUser`, already loaded at L51-168). Without this change every search that returns a team Task fails with 403. |
| Practitioner (L119-128), RelatedPerson (L262-271), Patient (L266-275) | `CommunicationRequest` | user or CareTeam in `getPeopleInMessage` (recipient, sender, requester) | Same check; covered by the `getPeopleInMessage` change in section 3. |
| Practitioner (L129-154), RelatedPerson (L272-294), Patient (L276-298) | `Communication` | user or CareTeam in the `partOf` thread's **recipient** | user or CareTeam in the `partOf` thread's **parties** (recipient plus extension team). Reuse `getPeopleInMessage` or add the extension explicitly. |
| RelatedPerson (L255-261), Patient (L259-265) | `Task` | owner is the RelatedPerson; `for` is the Patient | Unchanged. |

Tests: `ProxyRouterPractitionerAccessTest.java`, `ProxyRouterRelatedPersonAccessTest.java`, `ProxyRouterPatientAccessTest.java`. New cases: a Pharmacy A member who is not the requester reads `Pharmacy-to-Clinic` (200), its messages (200) and its team Task (200); a practitioner outside both teams gets nothing (empty Bundle, no 403).

#### 5. ReadListService (Task engine)

File: `service/ReadListService.java`. The engine runs asynchronously on Redis events (`service/MessageSubscriber.java` L104-153) after HAPI has accepted the write. It can therefore never reject a request; all 422 rules live in the validators (section 3). The engine assumes a validated resource.

**Thread parties.** Add a helper that returns the party references of a `CommunicationRequest`: every `recipient.reference` plus the extension team reference. Use it everywhere `getRecipient()` is used today: `handleNewCommunicationRequest` (L75-94), `readRecipientCareTeams` (L101-113), `readScopeOf` (L210-240), `handleMessageDeleted` (L403-475) and `handleCareTeamChange` (L260-279, see below).

**Task per party.** Replace `createTaskForParticipantsIfNoneExist(cr, careTeam, completed)` (L556-561) with a dispatch on the party type:

| Party | Task |
| --- | --- |
| CareTeam without `subject` (organizational) | one Task, `owner` = `CareTeam/<id>`, `ifNoneExist` = `Task?based-on=CommunicationRequest/<id>&owner=CareTeam/<id>` |
| CareTeam with `subject` (patient care team) | one Task per direct participant, as today (L573-604). A nested organizational CareTeam among the participants gets one team Task, not a Task per member. |
| Practitioner, RelatedPerson, Patient | one Task for that person, as today |

`for` is `cr.getSubject()` in all cases (the thread always has a patient subject).

**Initial status at thread creation.** `initiatingTeamMembers` (L133-155) becomes "acting parties at creation": the sender reference (`sender`, falling back to `requester` when `sender` is absent; `sender` is 0..1 in the profile) and the extension team reference. Their Tasks start `completed`, all others `requested`. No membership expansion.

**New Communication** (`handleNewCommunication`, L185-199):

1. Acting parties = the sender reference, plus the team in `Communication.extension[senderCareTeam]` when present.
2. Transition (0.9.0 only, *proposed* property `ozo.readlist.infer-acting-team`, default `true`): when the extension is absent, compute the candidate teams (organizational thread parties listing the sender) and, if there is exactly one, add it. The validator has already rejected the two-or-more case, so the engine never has to choose.
3. `markTasksAsUnread(tasks, actingParties, "Communication/<id>")` (L660-725) is unchanged: `completed` for Tasks whose `owner` is in the list, `requested` for the rest, `focus` set on all. Owner comparison on reference strings works for `CareTeam/<id>` as it does for `Practitioner/<id>`.
4. `readScopeOf` (L210-240) is no longer used for new messages; the team-wide read via member fan-out is gone.

**Read receipt** (`handleMessageRead`, L293-373):

1. Keep the type check (`iso-21089-lifecycle|access`), the required `CommunicationRequest` entity and the newest-message check on the optional `Communication` entity (`getNewestCommunication`, L525-542).
2. Acting party = the team in `agent.extension[careTeam]` of the requestor agent when present; otherwise, under the transition rule, the single candidate team; otherwise the `agent.who` reference itself.
3. Conditional patch of exactly one Task: `Task?based-on=CommunicationRequest/<id>&owner=<acting party>` with `replace /status completed` (L344-359). No fan-out to colleagues.
4. Note: the entity map is built with `Collectors.toMap` keyed on entity type (L307-309) and throws on two entities of the same type. A client that lists two `Communication` entities would crash the handler; make it tolerant while touching this method.

**Communication deleted** (`handleMessageDeleted`, L403-475): readers of the new latest message are derived from read receipt AuditEvents and the latest sender. Use the agent extension team (fallback `agent.who`) for the receipts and the Communication extension team (fallback `sender`) for the latest message, then `markTasksAsUnread` with the party list, as for a new message.

**CareTeam change** (`handleCareTeamChange`, L260-279):

- Search threads with `CommunicationRequest?participant=CareTeam/<id>` instead of `recipient=`.
- Organizational team (no `subject`): return without creating Tasks. The team's Task is shared; a new member sees it through the proxy scoping, a removed member loses access the same way. Removed members' per-person Tasks from before 0.9.0 are handled by migration M2.
- Patient care team: unchanged, create Tasks for new direct participants (`createTaskForParticipantsIfNoneExist`). The existing `TODO` about PATCH membership changes (L260) is unrelated to 0.9.0.

Tests: `service/ReadListServiceTest.java`, `service/ReadListServiceTeamMessagingTest.java` (`organisationalTeamChange_backfillsTasksForNewMembers` asserts the old backfill and must be inverted), `service/MessageSubscriberRetractionTest.java`. New cases follow the worked example on the team messaging page: two Tasks after creation (owner Clinic-B `requested`, owner Pharmacy-A `completed`); reply with extension Clinic-B flips both; read receipt with agent extension Pharmacy-A completes one Task and touches nothing else; a sender in two teams with the extension completes the named team only; absent extension with one candidate infers; patient care team threads behave as before.

#### 6. Configuration

| Property | 0.8.x | 0.9.0 |
| --- | --- | --- |
| `ozo.profile-injection.inject-sender-careteam-recipient` | `true` | Removed |
| `ozo.profile-injection.strip-sender-careteam-recipient` (*proposed*) | n/a | `true`; transition aid, removed in the next release |
| `ozo.validation.infer-acting-team` (*proposed*) | n/a | `true`; accept a missing extension when exactly one candidate team exists; removed in the next release |
| `ozo.readlist.infer-acting-team` (*proposed*) | n/a | Same default and lifetime as the validation property; both can be one property |

Document the final names on the [AAA Proxy](technical-aaa-proxy.html) configuration reference in the IG release that follows.

### Data migration (system user)

Run after the proxy is deployed (step 4 above). The system user is not scoped and may PATCH (`SystemAccessValidator` rejects DELETE only). Nothing is deleted; see [Resource Lifecycle](resource-lifecycle.html).

**M1. Duplicate recipients.** For every team thread, remove the initiating team from `recipient`.

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

Threads that are not cleaned stay readable (the union parameter matches either element) but fail validation on their next status update.

**M2. Team Tasks.** For every team thread and every organizational team party:

1. Read the member Tasks: `Task?based-on=CommunicationRequest/<id>&owner=Practitioner/<a>,Practitioner/<b>,...` for the team's direct participants.
2. Create the team Task with `ifNoneExist` = `Task?based-on=CommunicationRequest/<id>&owner=CareTeam/<team-id>`: `status` = `completed` when every member Task is `completed`, `requested` otherwise (also when a member has no Task); `focus` copied from the member Tasks (they all carry the same value); `intent`, `basedOn`, `for` as usual; `meta.profile` = OZOTask.
3. Set the member Tasks to `status` = `cancelled` (FHIRPath patch `replace Task.status`), so that `Task?status=requested` subscriptions stop matching them. Do this only for members whose Task exists because of the team; a practitioner who is also addressed individually or through a patient care team in the same thread keeps that per-person Task.
4. Patient care team Tasks are not touched.

Use a transaction Bundle per thread so that step 2 and step 3 succeed or fail together. Expect two Tasks per two-team thread afterwards; the team messaging feature has been in use since 0.6.0, so the volume is small. Verify with `Task?based-on=CommunicationRequest/<id>&status:not=cancelled`.

**M3. Stored Subscription criteria.** Subscription criteria are rewritten once at create time (snapshot) and the owner is stamped as `meta.tag`. Existing `CommunicationRequest` and `Communication` subscriptions therefore still carry `recipient=` and `part-of:CommunicationRequest.recipient=`. They keep firing for addressed threads but miss threads in which the subscriber's team is only the initiating team. Either rewrite them in place (`PUT` with `recipient=` replaced by `participant=` in `criteria`, keeping the owner tag) or ask the platforms to recreate them. `Task` subscriptions are not affected.

### Connecting platforms (OZO platform and others)

- Stop listing the own team in `CommunicationRequest.recipient`; put it in `extension[senderCareTeam]` only.
- Send `extension[senderCareTeam]` on every `Communication` written for a team, and `agent.extension[careTeam]` on every read receipt written for a team. The rule: required when the user participates in at least one organizational team of the thread; must be one of those teams. Platforms that know the user's teams can decide client-side; the proxy rejects mistakes with 422.
- Shared inbox: the team's unread threads are `Task?owner=CareTeam/<team>&status=requested`. A user in two teams gets one Task per team for the same thread. The plain `Task?status=requested` subscription keeps working and fires once per team Task change instead of once per member.
- Who personally read a message is no longer visible in Tasks. Use the read receipt AuditEvents (`AuditEvent?entity=CommunicationRequest/<id>&type=http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle|access`) when the user interface shows per-person read marks.
- During 0.9.0 an unchanged client works when every user is in at most one organizational team per thread; from the next release the extensions are mandatory.

### Verification checklist

Run against the e2e stack (`e2e/docker-compose.yaml`, HAPI 8.8 with the 0.9.0 package) with the Pharmacy A / Clinic B fixtures:

1. Otheeker (Pharmacy A) creates a thread addressed to Clinic B with the extension and without the duplicate recipient: 201. The same thread with Pharmacy A in `recipient`: 422 (or 201 with the entry stripped when the transition aid is on).
2. `Task?based-on=<thread>` as the system user returns exactly two Tasks: owner Clinic-B `requested`, owner Pharmacy-A `completed`.
3. Pieter (Pharmacy A, not the requester) reads the thread, its messages and `Task?status=requested`: 200, the thread and the Pharmacy A Task are in the results. Before the `getPeopleInMessage` and Task owner changes this is a 403.
4. Manu (Clinic B) posts a read receipt with `agent.extension[careTeam]` = Clinic-B: the Clinic B Task becomes `completed`; the Pharmacy A Task is unchanged.
5. Manu replies with `extension[senderCareTeam]` = Clinic-B: Pharmacy A Task `requested` with `focus` on the reply, Clinic B Task `completed` with the same `focus`. One `Task?status=requested` notification for the Pharmacy A subscription, none for Clinic B.
6. A practitioner who is a participant of both teams replies without the extension: 422. With the extension naming Clinic-B: only the Clinic B Task is completed.
7. Manu replies without the extension while being in exactly one team of the thread: 201, the engine infers Clinic B, an INFO line is logged.
8. A practitioner outside both teams searches `CommunicationRequest` and `Communication`: empty Bundles, no 403.
9. A RelatedPerson posts a `Communication` with `extension[senderCareTeam]`: 422.
10. Chained search `Communication?part-of:CommunicationRequest.participant=CareTeam/Pharmacy-A` as the system user returns the thread's messages; the same with `recipient` returns nothing for Pharmacy A.
11. Migration dry run on a copy of production data: counts of threads cleaned (M1), Tasks created and cancelled (M2), subscriptions rewritten (M3) match expectations before the real run.
