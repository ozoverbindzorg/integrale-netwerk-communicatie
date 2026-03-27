The OZO platform does not support deletion of individual FHIR resources. Instead, resources are managed through status transitions and, when legally required, through patient-level expunge operations.

### Why no DELETE

Deleting a FHIR resource breaks referential integrity across the system:

1. **AuditEvent references break** — NEN7510 requires audit events to reference the exact resource version that was accessed (`entity.what = {ResourceType}/{id}/_history/{version}`). Deleting the referenced resource makes the audit trail unverifiable. This has legal consequences — audit data may be used to determine who accessed what patient data.

2. **Subscription references break** — Deleting a Subscription that is referenced by audit events creates orphaned references that cannot be restored without manual intervention.

3. **Thread integrity breaks** — Deleting a `Communication` or `CommunicationRequest` leaves orphaned Tasks, AuditEvents, and other Communications with broken `partOf`, `basedOn`, and `inResponseTo` references.

4. **FHIR history is immutable** — Even after a DELETE, the `_history` endpoint retains previous versions. A DELETE adds a "deleted" marker but doesn't erase data. True erasure requires `$expunge`.

### Status-based lifecycle

Instead of DELETE, resources should transition through status values:

| Resource | "Active" status | "Removed" status | Notes |
|----------|----------------|------------------|-------|
| CommunicationRequest | `active` | `revoked` or `completed` | Thread closed or cancelled |
| Communication | `completed` | `entered-in-error` | Message retracted |
| Task | `requested` / `completed` | `cancelled` or `entered-in-error` | Task no longer relevant |
| CareTeam | `active` | `inactive` or `entered-in-error` | Team disbanded |
| Subscription | `requested` / `active` | `off` or `error` | Subscription deactivated |
| Patient | N/A | N/A | See Patient expunge below |
| Practitioner | N/A | N/A | Managed by care services directory |
| RelatedPerson | N/A | N/A | Managed by care network |

Status transitions preserve referential integrity — the resource still exists and can be referenced by AuditEvents, Tasks, and other resources. Applications should filter on status to hide "removed" resources from the user interface.

### Security labels

For resources that need to be hidden from certain users without changing their status, FHIR security labels can be used:

```
Resource.meta.security = http://terminology.hl7.org/CodeSystem/v3-Confidentiality#R "restricted"
```

The AAA proxy can filter resources based on security labels, making them invisible to unauthorized users while preserving referential integrity.

### Patient expunge (right to erasure)

The only supported way to truly remove data is the HAPI FHIR `$expunge` operation, which is used exclusively for **AVG/GDPR right-to-erasure** requests. This operation:

1. Permanently removes all versions of a resource from the database
2. Should be applied at the Patient level, cascading to all related resources
3. Is an administrative operation — not available through the normal API
4. Must be logged separately (the expunge itself is an auditable event)

```
POST /fhir/Patient/{id}/$expunge
Content-Type: application/fhir+json

{
  "resourceType": "Parameters",
  "parameter": [
    {"name": "expungeDeletedResources", "valueBoolean": true},
    {"name": "expungePreviousVersions", "valueBoolean": true}
  ]
}
```

> **Important:** `$expunge` is irreversible and destroys audit trail data. It should only be used for legally mandated data erasure (AVG/GDPR Article 17). All other "removal" scenarios should use status transitions.
{:.stu-note}

### CapabilityStatement alignment

The OZO CapabilityStatements ([OZO-System](CapabilityStatement-OZO-System.html), [OZO-Client](CapabilityStatement-OZO-Client.html)) do not include `delete` as a supported interaction on any resource. This is intentional — the API does not support DELETE operations.

### Proxy enforcement

The AAA proxy should reject DELETE requests with HTTP 405 Method Not Allowed. The `$expunge` operation should only be available to system-level credentials and should be gated behind additional authorization checks.
