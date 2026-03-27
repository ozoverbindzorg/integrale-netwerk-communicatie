The OZO FHIR API uses CapabilityStatements to declare what the server supports. The API proxy serves the appropriate CapabilityStatement based on the caller's credentials.

### How it works

The `/metadata` endpoint returns different CapabilityStatements depending on authentication:

| Request | Returns | Description |
|---------|---------|-------------|
| Unauthenticated | [OZO-Server](CapabilityStatement-OZO-Server.html) | Server identity, security requirements, supported profiles. No interactions listed — authenticate first. |
| System credentials | [OZO-System](CapabilityStatement-OZO-System.html) | Full CRUD access to all resources. |
| Client credentials | [OZO-Client](CapabilityStatement-OZO-Client.html) | Read/write scoped by the proxy based on the caller's role and CareTeam memberships. |

The [OZO-Client](CapabilityStatement-OZO-Client.html) CapabilityStatement applies to all three client roles: **Practitioner**, **RelatedPerson**, and **Patient**. These roles share the same resource types and interactions — the difference is how the AAA proxy scopes access.

### Access filtering by the AAA proxy

The OZO AAA proxy sits between clients and the FHIR server. It automatically applies search filters to scope results to the authenticated user's access level. Clients do not need to add these filters — the proxy rewrites the query parameters transparently.

For example, when a practitioner searches for `GET /fhir/Patient`, the proxy rewrites this to:
```
GET /fhir/Patient?_has:CareTeam:patient:participant={practitionerReference}
```

This ensures the practitioner only sees patients in their CareTeams, without the client needing to know the filtering logic.

### Per-role scoping

The tables below show the search filters the proxy auto-applies for each role. The `{self}` placeholder represents the authenticated user's FHIR reference(s).

#### Practitioner

Authenticated via NutsOrganizationCredential + NutsEmployeeCredential. Access is scoped to CareTeams where the practitioner is a participant.

| Resource | Proxy auto-applied filter |
|----------|--------------------------|
| Patient | `_has:CareTeam:patient:participant={self}` |
| Practitioner | `_has:CareTeam:participant:participant={self}` |
| RelatedPerson | `_has:CareTeam:participant:participant={self}` |
| CareTeam | `participant={self}` |
| CommunicationRequest | `recipient={self OR careTeams}` |
| Communication | `part-of:CommunicationRequest.recipient={self OR careTeams}` |
| Task | `owner={self OR careTeams}` |
| AuditEvent | `agent={careTeamPractitioners}` (all practitioners in shared CareTeams) |
| Subscription | criteria rewritten with above filters |

#### RelatedPerson

Authenticated via OzoUserCredential. Access is scoped to the related person's own profile and their CareTeam memberships.

| Resource | Proxy auto-applied filter |
|----------|--------------------------|
| Patient | `_has:RelatedPerson:patient:identifier={self}` |
| Practitioner | `_has:CareTeam:participant:participant={self}` |
| RelatedPerson | `identifier={self}` (own profile only) |
| CareTeam | `participant={self}` |
| CommunicationRequest | `recipient={self OR careTeams}` |
| Communication | `part-of:CommunicationRequest.recipient={self OR careTeams}` |
| Task | `owner={self}` |
| AuditEvent | `agent={self OR careTeams}` |
| Subscription | criteria rewritten with above filters |

#### Patient

Access is scoped to the patient's own record and CareTeams where the patient is the subject.

| Resource | Proxy auto-applied filter |
|----------|--------------------------|
| Patient | `identifier={self}` (own record only) |
| Practitioner | `_has:CareTeam:participant:patient={self}` |
| RelatedPerson | `patient={self}` |
| CareTeam | `patient={self}` |
| CommunicationRequest | `recipient={self OR careTeams}` |
| Communication | `part-of:CommunicationRequest.recipient={self OR careTeams}` |
| Task | `patient={self}` |
| AuditEvent | `agent={self OR careTeams}` |
| Subscription | criteria rewritten with above filters |

### Write validation

For write operations (POST/PUT), the proxy validates the resource content regardless of role:

| Resource | Validation rule |
|----------|----------------|
| Communication | `sender` must be the authenticated user |
| CommunicationRequest | `requester` must be the authenticated user |
| AuditEvent | `agent[requestor=true].who` must be the authenticated user |
| Subscription | `criteria` is rewritten to scope results to the user's access |

### Subscription support

All CapabilityStatements include Subscription support. Subscriptions use the **notify-then-pull** pattern required in Dutch healthcare:

1. The FHIR server sends an **empty notification** (no resource payload) to the subscriber's endpoint
2. The subscriber **pulls** the changed resource by performing a FHIR read or search

The proxy automatically rewrites Subscription criteria to scope notifications to the user's access level, similar to search query rewriting.

See the [Individual Messaging](interaction-messaging.html) and [Team-to-Team Messaging](interaction-messaging-team.html) pages for detailed Subscription examples and behavior.

### CapabilityStatements

* [OZO-Server](CapabilityStatement-OZO-Server.html) — Base (unauthenticated): server identity, security requirements, profiles
* [OZO-System](CapabilityStatement-OZO-System.html) — System access: full CRUD, no access filters
* [OZO-Client](CapabilityStatement-OZO-Client.html) — Client access (Practitioner, RelatedPerson, Patient): read/write scoped by proxy
