The OZO FHIR API uses role-based CapabilityStatements to declare what each type of client can do. The API proxy serves the appropriate CapabilityStatement based on the caller's credentials.

### How it works

The `/metadata` endpoint returns different CapabilityStatements depending on authentication:

| Request | Returns | Description |
|---------|---------|-------------|
| Unauthenticated | [OZO-Server](CapabilityStatement-OZO-Server.html) | Server identity, security requirements, supported profiles. No interactions listed — authenticate first. |
| System credentials | [OZO-System](CapabilityStatement-OZO-System.html) | Full CRUD access to all resources. |
| Practitioner credentials | [OZO-Practitioner](CapabilityStatement-OZO-Practitioner.html) | Read/write scoped to CareTeam memberships. |
| RelatedPerson credentials | [OZO-RelatedPerson](CapabilityStatement-OZO-RelatedPerson.html) | Read/write scoped to own profile and CareTeam memberships. |
| Patient credentials | [OZO-Patient](CapabilityStatement-OZO-Patient.html) | Read/write scoped to own record and CareTeam memberships. |

### Access filtering by the AAA proxy

The OZO AAA proxy sits between clients and the FHIR server. It automatically applies search filters to scope results to the authenticated user's access level. Clients do not need to add these filters — the proxy rewrites the query parameters transparently.

For example, when a practitioner searches for `GET /fhir/Patient`, the proxy rewrites this to:
```
GET /fhir/Patient?_has:CareTeam:patient:participant={practitionerReference}
```

This ensures the practitioner only sees patients in their CareTeams, without the client needing to know the filtering logic.

### Write validation

For write operations (POST/PUT), the proxy validates the resource content:

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

* [OZO-Server](CapabilityStatement-OZO-Server.html) — Base (unauthenticated)
* [OZO-System](CapabilityStatement-OZO-System.html) — System access (full CRUD)
* [OZO-Practitioner](CapabilityStatement-OZO-Practitioner.html) — Practitioner access (CareTeam-scoped)
* [OZO-RelatedPerson](CapabilityStatement-OZO-RelatedPerson.html) — RelatedPerson access (own profile + CareTeam-scoped)
* [OZO-Patient](CapabilityStatement-OZO-Patient.html) — Patient access (own record + CareTeam-scoped)
