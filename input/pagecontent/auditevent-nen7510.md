# AuditEvent for NEN7510 Compliance

## Overview

The OZO AAA Proxy implements comprehensive audit logging to comply with NEN7510 (Dutch healthcare security standard) requirements. All FHIR operations passing through the proxy are captured as FHIR AuditEvent resources that provide complete traceability and accountability.

## Key Features

### NEN7510 Compliance

The implementation ensures:

1. **Complete Audit Trail**: All CRUD operations are audited
2. **Immutability**: Audit events cannot be modified after creation
3. **Traceability**: Full request tracing with W3C Trace Context
4. **Attribution**: All actions linked to specific users/devices
5. **Tamper Evidence**: Audit events are append-only
6. **Comprehensive Coverage**: Success and failure scenarios captured

### Distributed Tracing

The OZO AAA Proxy implements W3C Trace Context for distributed tracing across all API calls. See [W3C Trace Context Support](w3c-trace-context.html) for detailed information about trace propagation and usage.

## AuditEvent Structure

### Profile: OZOAuditEvent

The OZO AuditEvent profile extends the base FHIR AuditEvent with specific constraints and extensions:

#### Core Elements

- **type**: REST operation or transmit event (required)
- **subtype**: Specific FHIR interaction (read, create, update, delete, search, etc.)
- **action**: CRUD operation code (C, R, U, D, E) (required)
- **outcome**: Success (0), minor failure (4), or major failure (8) (required)
- **outcomeDesc**: Description of the outcome, particularly for failures
- **recorded**: When the event was recorded (required)

#### Agent Information

- **agent**: Who performed the action (1..* required)
  - **type**: Agent type (Source Role ID, Application, etc.)
  - **who**: Reference to Practitioner, RelatedPerson, or Device
  - **requestor**: Whether the agent initiated the action

#### Source Information

- **source**: The OZO AAA Proxy system
  - **site**: Logical source location
  - **observer**: Reference to the proxy Device resource
  - **type**: Application Server

#### Entity Information

- **entity**: What was accessed/modified (0..*)
  - **what**: Reference to the specific FHIR resource
  - **type**: Type of resource
  - **role**: Domain Resource or Query
  - **query**: For searches, the query parameters used

#### Extensions

- **trace-id**: 32-character hex trace ID from W3C Trace Context
- **span-id**: 16-character hex span ID from W3C Trace Context
- **resource-origin**: Device that originally created the resource

## Examples

The following examples demonstrate various AuditEvent scenarios in the OZO AAA Proxy:

### Practitioner Access Events
* [AuditEvent-Practitioner-Manu-Access](AuditEvent-Practitioner-Manu-Access.html) - Practitioner accessing Communication resources
* [AuditEvent-Practitioner-Mark-Access](AuditEvent-Practitioner-Mark-Access.html) - Another Practitioner access example

### RelatedPerson Access Events
* [AuditEvent-RelatedPerson-Access](AuditEvent-RelatedPerson-Access.html) - RelatedPerson accessing Communication resources

### REST Operation Events
* [AuditEvent-REST-Create-Example](AuditEvent-REST-Create-Example.html) - Successful REST create operation
* [AuditEvent-REST-Search-Example](AuditEvent-REST-Search-Example.html) - REST search operation
* [AuditEvent-REST-Update-Failure](AuditEvent-REST-Update-Failure.html) - Failed update operation with authorization error

### System Access Events
* [AuditEvent-System-Access](AuditEvent-System-Access.html) - System-to-system access using DID identifiers

## Implementation Details

### Asynchronous Processing

The OZO AAA Proxy implements asynchronous audit event processing to avoid blocking request handling:

1. Audit events are captured during request processing
2. Events are submitted asynchronously with a configurable delay (default 2 seconds)
3. This approach avoids referential integrity issues when auditing resource creation
4. Failures in audit event submission do not affect the primary request

### Configuration

The following configuration options are available:

```properties
# Audit Event Configuration (NEN7510 compliance)
audit.enabled=true                    # Enable/disable audit logging
audit.delay.seconds=2                 # Delay before persisting events
audit.site=AAA Proxy OZO             # Site name for audit events
audit.observer.system=aaa-proxy       # Observer system identifier
audit.observer.value=aaa-proxy-001    # Observer instance identifier
```

### Event Type Mappings

- REST Operations → `http://terminology.hl7.org/CodeSystem/audit-event-type` "rest"
- Notifications → `http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle` "transmit"

### Action Codes

- Create → "C"
- Read/Search → "R"
- Update → "U"
- Delete → "D"
- Execute → "E"

### Outcome Codes

- "0" → Success
- "4" → Minor failure (4xx errors)
- "8" → Major failure (5xx errors)

## Security Considerations

1. **Audit Event Integrity**: Audit events are immutable once created
2. **Access Control**: Only authorized systems can read audit events
3. **Retention**: Audit events must be retained according to NEN7510 requirements
4. **Monitoring**: Regular monitoring of audit events for security incidents
5. **Privacy**: Patient identifiable information in audit events must be protected

## Future Enhancements

1. Support for subscription notification auditing
2. Implement audit event integrity checking with digital signatures
3. Add batch audit event submission for performance optimization
4. Support for custom audit event extensions
5. Integration with external audit log management systems