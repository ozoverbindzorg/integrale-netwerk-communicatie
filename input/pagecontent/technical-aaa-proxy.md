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
| Task | `owner` | Only tasks owned by the user or their CareTeams |
| CommunicationRequest | `recipient` | Only threads where the user or their CareTeam is a recipient |
| Communication | `part-of:CommunicationRequest.recipient` | Only messages in threads the user has access to |
| AuditEvent | `agent` | Read receipts from the user and all CareTeam members (expanded to individual Practitioner references) |

**AuditEvent note:** Unlike other resources, `AuditEvent.agent.who` is always a Practitioner reference, never a CareTeam. The proxy expands CareTeam membership to individual Practitioner references using `CareTeamService.flattenCareTeamsToPractitioners()`, which recursively resolves nested CareTeams with cycle protection.

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

### Content validation (POST/PUT)

After profile and default injection, the proxy validates the request body:

- **Communication**: sender must match the authenticated user; recipients must be in a shared CareTeam
- **CommunicationRequest**: requester must match the authenticated user
- **AuditEvent**: requestor agent must match the authenticated user
- **Subscription**: endpoint must use HTTPS, must not point to internal networks, payload must be empty (non-empty payloads bypass the proxy), criteria must reference an allowed resource type

Subscription criteria are also rewritten to scope them to the authenticated user (e.g., `Task?status=requested` becomes `Task?status=requested&owner=Practitioner/x,CareTeam/y`).

### Response validation

After receiving the FHIR server's response, the proxy validates that all returned resources fall within the user's access scope. This is a second line of defense — if query rewriting failed to scope results correctly, response validation catches it.

Resources that fail validation cause the proxy to return `403 Forbidden` with a JSON error (not a FHIR OperationOutcome).

### Event publishing (Redis)

Successful POST, PUT, DELETE, and PATCH operations trigger Redis publication of the response body. The `ReadListService` subscribes to these events and processes:

| Event | Action |
|---|---|
| New CommunicationRequest | Creates Tasks for all CareTeam member recipients |
| New Communication | Sets Task status to `requested` for all thread participants except the sender |
| CareTeam change | Creates Tasks for new members if a CommunicationRequest exists |
| AuditEvent (message read) | Sets Task status to `completed` for the reading practitioner |
| Communication deleted | Recalculates Task statuses based on the new latest message |

**Task subscription behavior:** When a new message arrives and a Task is already `requested` (unread), setting it to `requested` again is a no-op — HAPI FHIR does not create a new resource version, so Task subscriptions do not fire. To detect new messages, subscribe to `Communication`, not `Task`. See [Individual Messaging](interaction-messaging.html) for subscription guidance.

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

#### Task subscription not firing

If Task subscriptions do not fire on new messages, the Task was likely already in `requested` status. HAPI does not create a new version when nothing changes. Subscribe to `Communication?id` for reliable new-message detection.

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
| `readlist.force-task-update` | `false` | Patch `Task.lastModified` to force subscription triggers (workaround) |
| `fhir.search.max-count` | `100` | Maximum allowed `_count` parameter value |
| `fhir.pagination.ttl-minutes` | `30` | Redis TTL for pagination tokens |
| `audit.enabled` | `true` | Enable/disable NEN7510 audit logging |
| `audit.delay.seconds` | `2` | Delay before persisting audit events (avoids referential integrity issues) |
