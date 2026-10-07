The OZO AAA Proxy sits between clients and the HAPI FHIR server, enforcing access control, injecting metadata, and publishing events. This page documents all request and response modifications the proxy performs, from the perspective of a developer integrating with or troubleshooting the OZO FHIR API.

### Request flow

Every request passes through these stages in order:

1. **Trace context** — W3C `traceparent` header is parsed or generated (see [W3C Trace Context](w3c-trace-context.html))
2. **Audit event capture** — request details are recorded for NEN7510 audit logging (see [AuditEvent NEN7510](auditevent-nen7510.html))
3. **Cache-Control check** — `Cache-Control: no-store` is rejected with 400 (incompatible with audit logging and pagination)
4. **Access validation** — user type is determined from the access token and the appropriate validator is selected
5. **Query rewriting** (GET) — search parameters are injected to scope results to the user's access
6. **Profile injection** (POST/PUT) — `meta.profile` is set to the correct OZO profile
7. **Default value injection** (POST/PUT) — required fields are filled in if absent
8. **Content validation** (POST/PUT) — request body is validated against access rules
9. **Forward to HAPI** — the modified request is sent to the FHIR server
10. **Response validation** — returned resources are checked against the user's access scope
11. **Event publishing** — successful write operations are published to Redis for subscription processing

### Query rewriting (GET requests)

On search requests, the proxy appends search parameters to scope results to the authenticated user. The original query parameters are preserved; the proxy adds additional constraints.

| Resource type | Injected parameter | Example |
|---|---|---|
| Practitioner | `_has:CareTeam:participant:participant` | Only practitioners in shared CareTeams |
| Patient | `_has:CareTeam:patient:participant` | Only patients in the user's CareTeams |
| RelatedPerson | `_has:CareTeam:participant:participant` | Only related persons in shared CareTeams |
| CareTeam | `participant` | Only CareTeams the user belongs to |
| Task | `owner` | Only tasks owned by the user or by one of their CareTeams (team Tasks of organizational teams) |
| CommunicationRequest | `participant` | Only threads in which the user or their CareTeam is a party: addressed in `recipient` or initiating team in `extension[senderCareTeam]`. Custom union search parameter, see [CapabilityStatements](capability-statements.html#custom-search-parameters) |
| Communication | `part-of:CommunicationRequest.participant` | Only messages in threads the user has access to |
| AuditEvent | `agent` | Read receipts from the user and all CareTeam members (expanded to individual Practitioner references) |

The injected value is a comma-separated list of the user's own reference(s) and the CareTeams they participate in, so one parameter covers person and teams. FHIR combines different parameters with AND and `_filter` is blocked, which is why thread scoping uses the `participant` union parameter rather than `recipient` plus `sender-careteam`.

**AuditEvent note:** Unlike other resources, `AuditEvent.agent.who` is always a Practitioner reference, never a CareTeam. The proxy expands CareTeam membership to individual Practitioner references using `CareTeamService.flattenCareTeamsToPractitioners()`, which recursively resolves nested CareTeams with cycle protection. The team a read receipt was made for is in `agent.extension[careTeam]`, which is not a search parameter.

### Search parameter restrictions

The proxy blocks search parameters that could bypass access control or cause performance issues:

| Blocked parameter | Reason |
|---|---|
| `_include`, `_revinclude` | Could return resources outside the user's access scope |
| `_filter` | Arbitrary filter expressions bypass scoped search parameters |
| `_contained` | Contained resources bypass response validation |
| `_has` with non-allowed resource types | Prevents information leakage via reverse chaining |
| `_format` with non-JSON values | The proxy only parses JSON; non-JSON responses would bypass validation |
| `_count` > 100 | Capped to prevent OOM (configurable via `fhir.search.max-count`) |

FHIR operations (`$everything`, `$validate`, etc.) are rejected entirely.

### Profile injection (POST/PUT)

On write operations, the proxy sets `meta.profile` to the correct OZO profile canonical URL. Any existing `meta.profile` set by the client is **overwritten** — the proxy is authoritative.

| Resource type | Profile |
|---|---|
| Patient | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPatient` |
| Practitioner | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner` |
| RelatedPerson | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson` |
| Organization | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOOrganization` |
| CommunicationRequest | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunicationRequest` |
| Communication | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication` |
| Task | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask` |
| AuditEvent | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOAuditEvent` |
| CareTeam (with subject) | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCareTeam` |
| CareTeam (without subject) | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOOrganizationalCareTeam` |
| Subscription | No profile injected — passed through unchanged |

CareTeam requires body inspection: if `CareTeam.subject` is set, the patient CareTeam profile is used; otherwise, the organizational CareTeam profile is used.

The profile mapping is configurable via `ozo.profile-injection.mappings`. Profile injection can be disabled entirely with `ozo.profile-injection.enabled=false`.

### Default value injection (POST/PUT)

The proxy injects required field values when clients omit them:

| Resource type | Field | Default value | Reason |
|---|---|---|---|
| Communication | `status` | `preparation` | Required by R4 but often omitted by clients. The value `preparation` indicates the resource was injected by the proxy, not explicitly set by the client. |

This is controlled by `ozo.profile-injection.inject-communication-status` (default: `true`). Existing values are never overwritten.

Up to fhir.ozo 0.8.4 the proxy also added the team in `extension[senderCareTeam]` to `CommunicationRequest.recipient` when a client left it out (`ozo.profile-injection.inject-sender-careteam-recipient`). With 0.9.0 that duplicate is deprecated. The injection stays on as long as the proxy scopes threads on `recipient=` and is switched off together with the move to `participant=` scoping; the two are controlled by one flag. A duplicate sent by a 0.8.x client is neither stripped nor rejected; HAPI accepts it with a validation warning. See [AAA Proxy - Changes for 0.9.0](technical-aaa-proxy-0-9-0.html).

### Content validation (POST/PUT)

After profile and default injection, the proxy validates the request body:

- **Communication**: `sender` must match the authenticated user; `partOf` must reference a thread the user is a party of. When `extension[senderCareTeam]` is present it must reference an organizational CareTeam that is a party of the thread and lists the user as a participant (422 otherwise). When it is absent and the user participates in an organizational team of the thread, 0.9.0 infers the team (see the transition below); from the release after 0.9.0 the extension is required
- **CommunicationRequest**: `requester` (and `sender`, when set) must match the authenticated user; `extension[senderCareTeam]`, when set, must be an organizational CareTeam (no `subject`) the user is a participant of. It should not be repeated in `recipient`; the duplicate is accepted in 0.9.0 (HAPI reports a validation warning) and ignored
- **AuditEvent**: requestor agent must match the authenticated user. For a read receipt (type `iso-21089-lifecycle|access`), `agent.extension[careTeam]`, when present, must reference one of the user's organizational teams in that thread (422 otherwise); when absent, 0.9.0 infers the team as for `Communication`
- **Subscription**: endpoint must use HTTPS, must not point to internal networks, payload must be empty (non-empty payloads bypass the proxy), criteria must reference an allowed resource type

Subscription criteria are also rewritten to scope them to the authenticated user (e.g., `Task?status=requested` becomes `Task?status=requested&owner=Practitioner/x,CareTeam/y`).

### Response validation

After receiving the FHIR server's response, the proxy validates that all returned resources fall within the user's access scope. This is a second line of defense — if query rewriting failed to scope results correctly, response validation catches it.

For threads and messages, the user is in scope when their own reference or one of their CareTeams is a thread party: `recipient`, `extension[senderCareTeam]`, `sender` or `requester` of the `CommunicationRequest`. A `Task` is in scope when `owner` is the user or one of the user's organizational CareTeams.

Resources that fail validation cause the proxy to return `403 Forbidden` with a JSON error (not a FHIR OperationOutcome).

### Event publishing (Redis)

Successful POST, PUT, DELETE, and PATCH operations trigger Redis publication of the response body. The `ReadListService` subscribes to these events and processes:

The thread parties are the set union of `CommunicationRequest.recipient` and `extension[senderCareTeam]`. Each party gets Tasks by its type: one Task per member of a patient CareTeam (with `subject`) or individually addressed person, with `owner` the person; one Task per organizational CareTeam (no `subject`), with `owner` the CareTeam. The table describes this 0.9.0 team-Task mode. In the 0.8.x mode, which an environment may keep during the 0.9.0 transition, an organizational CareTeam gets one Task per member and reads are fanned out to the team's members (team-wide read), as documented up to 0.8.4.

| Event | Action |
|---|---|
| New CommunicationRequest | Creates the Tasks of all thread parties. The Task of the sender (and of the sender's team in `extension[senderCareTeam]`) starts `completed`; all other Tasks start `requested`. |
| New Communication | The acting party is the sender, or the team in `Communication.extension[senderCareTeam]` when present. Its Task is set to `completed`; every other party's Task is set to `requested`. All Tasks get `focus` = the new `Communication`. |
| CareTeam change | Patient CareTeam: creates Tasks for new members if a CommunicationRequest exists. Organizational CareTeam: no Task handling; the team's Task is shared and access follows the proxy scoping. |
| AuditEvent with type `iso-21089-lifecycle` / `access` (read receipt) | Sets the Task of the acting party to `completed`: the Task owned by the team in `agent.extension[careTeam]` when present, the Task owned by the reader in `agent.who` otherwise. Only when the `Communication` entity (if present) is the newest message in the thread. AuditEvents with any other type, such as the proxy's own `rest` events, are ignored. |
| Communication deleted | Recalculates Task statuses based on the new latest message |

**Transition in 0.9.0:** when `extension[senderCareTeam]` on a `Communication` or `agent.extension[careTeam]` on a read receipt is absent, the `ReadListService` uses the person's organizational team in the thread when there is exactly one, and falls back to the 0.8.x behaviour (all of the person's organizational teams in the thread) when there are more, with a warning in the proxy log. The inference and the fallback are removed in the release after 0.9.0. Which Task mode (per member or per team) and which scoping (`recipient` or `participant`) an environment runs is set by configuration; see [AAA Proxy - Changes for 0.9.0](technical-aaa-proxy-0-9-0.html).

**Task subscription behavior:** On every new message the `ReadListService` patches each Task in the thread: `status` becomes `requested` or `completed` as described above, and `focus` is set to the new `Communication`. The `focus` change creates a new Task version even when the status was already `requested`, so a `Task?status=requested` subscription fires on every new message and is the only subscription a client needs. See [Individual Messaging](interaction-messaging.html) and [Team-to-Team Messaging](interaction-messaging-team.html) for subscription guidance.

### Troubleshooting

#### Request rejected with 400

| Error | Cause |
|---|---|
| `Cache-Control: no-store is not supported` | Client sends `Cache-Control: no-store`. Use `no-cache` instead. |
| `FHIR operations are not supported` | Client calls a FHIR operation like `$everything`. Operations are blocked. |
| `Search parameters not supported: [_include]` | Client uses a blocked search parameter. |
| `Only JSON format is supported` | Client requests XML, Turtle, or RDF via `_format` or `Accept` header. |
| `Invalid _count value` | Non-numeric `_count` parameter. |

#### Request rejected with 401

Authentication failed — the access token is missing, expired, or invalid. See [Authentication](ozo-authentication-overview.html).

#### Request rejected with 403

| Error | Cause |
|---|---|
| `A FHIR resource was requested that is not allowed` | Response validation detected a resource outside the user's access scope. This is a second-line defense — check whether query rewriting is correct for this user type. |
| `Denied access for GET/HEAD method` | The resource type is not in the allowlist for read access. |
| `Denied modification access for method: POST` | The resource type is not in the allowlist for write access. |
| `Subscription endpoint must use HTTPS` | Subscription endpoint is HTTP, not HTTPS. |
| `Subscription payload must be empty` | Non-empty subscription payloads bypass the proxy. |

#### Request rejected with 422

| Error | Cause |
|---|---|
| `senderCareTeam is not a party of this thread` (Communication) | `extension[senderCareTeam]` names a team that is neither in `recipient` nor in `extension[senderCareTeam]` of the `CommunicationRequest`, or the sender is not a participant of it. |
| `agent careTeam is not a party of this thread` (AuditEvent) | Same rule, applied to `agent.extension[careTeam]` on a read receipt. |
| `senderCareTeam is required` (Communication), `agent careTeam is required` (AuditEvent) | Only from the release after 0.9.0, or in 0.9.0 when the inference is switched off: the person participates in an organizational CareTeam of the thread but the extension is missing. In 0.9.0 with inference on, the request is accepted and the team is inferred. |
| `senderCareTeam` extension on a RelatedPerson or Patient write | Related persons and patients are never participants of an organizational team, so the extension must be absent. |

Not a rejection: a `CommunicationRequest` that repeats the initiating team in `recipient` (the 0.8.x shape) is accepted in 0.9.0; HAPI reports the warning `ozo-cr-sender-careteam-not-in-recipient` in validation output. Remove the duplicate before the release after 0.9.0, where the invariant becomes an error.

The message texts are indicative; the proxy returns a FHIR `OperationOutcome` for HAPI validation failures and a JSON error for its own checks.

#### Task subscription not firing

The proxy patches `Task.focus` on every new message, so `Task?status=requested` fires even when the Task was already unread. If it does not fire, check the following:

- The Task has an `owner`. The `ReadListService` skips Tasks without one.
- The subscriber is not the acting party. The Task of the sender, or of the team named in `extension[senderCareTeam]`, is set to `completed` and does not match `status=requested`; subscribe to `Task?` (every Task change) to see those transitions as well.
- For a team thread in the team-Task mode, the subscriber is a participant of the organizational CareTeam that owns the Task. The proxy adds the user's CareTeams to `owner=` when it rewrites the criteria; a practitioner who left the team no longer matches.
- The proxy in use patches `focus` (required since fhir.ozo 0.7.5). Older proxy versions only patched `status`, which is a no-op when the Task is already `requested`.
- In the team-Task mode, the proxy in use is at least the version that implements fhir.ozo 0.9.0. Older versions reject team Tasks in response validation (403).

#### `meta.profile` is different from what the client sent

The proxy overwrites `meta.profile` on POST/PUT. This is intentional — the proxy is authoritative for profile assignment. Clients should not rely on their own `meta.profile` being preserved.

### Configuration reference

| Property | Default | Description |
|---|---|---|
| `ozo.profile-injection.enabled` | `true` | Enable/disable profile injection on POST/PUT |
| `ozo.profile-injection.mappings` | *(see profile table above)* | Resource type → profile URL mapping |
| `ozo.profile-injection.careteam.with-subject` | `...OZOCareTeam` | Profile for patient CareTeams |
| `ozo.profile-injection.careteam.without-subject` | `...OZOOrganizationalCareTeam` | Profile for organizational CareTeams |
| `ozo.profile-injection.inject-communication-status` | `true` | Inject `Communication.status = preparation` when absent |
| `fhir.search.max-count` | `100` | Maximum allowed `_count` parameter value |
| `fhir.pagination.ttl-minutes` | `30` | Redis TTL for pagination tokens |
| `audit.enabled` | `true` | Enable/disable NEN7510 audit logging |
| `audit.delay.seconds` | `2` | Delay before persisting audit events (avoids referential integrity issues) |
