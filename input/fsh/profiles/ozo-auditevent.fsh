Profile: OZOAuditEvent
Parent: AuditEvent
Id: ozo-auditevent
Title: "OZO AuditEvent"
Description: "AuditEvent profile for OZO AAA Proxy to comply with NEN7510 standards"
* ^version = "1.0.0"
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// Mandatory elements
* type 1..1 MS
* type from OZOAuditEventTypeVS (required)
* type ^short = "Type of event (rest, transmit)"
* type ^definition = "Type of audit event - either REST operation or notification transmission"

* subtype 0..* MS
* subtype from OZOAuditEventSubtypeVS (extensible)
* subtype ^short = "Specific type of event (read, create, update, delete, search, capabilities)"
* subtype ^definition = "More specific type of event within the broader category"

* action 1..1 MS
* action ^short = "Type of action performed (C,R,U,D,E)"
* action ^definition = "Indicator for type of action performed during the event that generated the audit"

* recorded 1..1 MS
* recorded ^short = "When the event was recorded"
* recorded ^definition = "The time when the event was recorded"

* outcome 1..1 MS
* outcome ^short = "Whether the event succeeded or failed"
* outcome ^definition = "Indicates whether the event succeeded or failed. 0=Success, 4=Minor failure, 8=Major failure"

* outcomeDesc 0..1 MS
* outcomeDesc ^short = "Description of the event outcome"
* outcomeDesc ^definition = "Text description of the outcome, particularly for failures"

// Agent - who performed the action
* agent 1..* MS
* agent ^short = "Actor involved in the event"
* agent ^definition = "An actor taking an active role in the event or activity that is logged"
* agent.type 0..1 MS
* agent.type from OZOAuditEventAgentTypeVS (extensible)
* agent.who 1..1 MS
* agent.who only Reference(Practitioner or RelatedPerson or Device)
* agent.who ^short = "Identifier of who performed the action"
* agent.who ^definition = "Reference to the resource for the user who performed the action"
* agent.requestor 1..1 MS
* agent.requestor ^short = "Whether user is initiator"
* agent.requestor ^definition = "Indicator that the user is or is not the requestor, or initiator, for the event being audited"

// Source - the OZO AAA Proxy
* source 1..1 MS
* source.site 0..1 MS
* source.site ^short = "Logical source location within the enterprise"
* source.site ^definition = "Logical source location within the healthcare enterprise network"
* source.observer 1..1 MS
* source.observer only Reference(Device)
* source.observer ^short = "The identity of source detecting the event"
* source.observer ^definition = "Identifier of the source where the event was detected (OZO AAA Proxy)"
* source.type 1..* MS
* source.type from OZOAuditEventSourceTypeVS (extensible)

// Entity - what was accessed/modified
* entity 0..* MS
* entity ^short = "Data or objects used"
* entity ^definition = "Specific instances of data or objects that have been accessed"
* entity.what 1..1 MS
* entity.what ^short = "Specific resource accessed"
* entity.what ^definition = "Reference to the specific FHIR resource that was accessed or modified"
* entity.type 0..1 MS
* entity.type from OZOAuditEventEntityTypeVS (extensible)
* entity.role 0..1 MS
* entity.lifecycle 0..1 MS
* entity.query 0..1 MS
* entity.query ^short = "Query parameters if applicable"
* entity.query ^definition = "For search operations, the query parameters used"

// Extensions for W3C Trace Context and additional metadata
* extension contains
    OZOTraceId named traceId 0..1 MS and
    OZOSpanId named spanId 0..1 MS and
    OZOResourceOrigin named resourceOrigin 0..1 MS

// Define the extensions
Extension: OZOTraceId
Id: ozo-trace-id
Title: "OZO Trace ID"
Description: "W3C Trace Context trace-id for distributed tracing"
* value[x] only string
* valueString 1..1
* valueString ^short = "32-character hex trace ID"
* valueString ^definition = "The trace-id from W3C Trace Context header"

Extension: OZOSpanId
Id: ozo-span-id
Title: "OZO Span ID"
Description: "W3C Trace Context span-id for distributed tracing"
* value[x] only string
* valueString 1..1
* valueString ^short = "16-character hex span ID"
* valueString ^definition = "The span-id from W3C Trace Context header"

Extension: OZOResourceOrigin
Id: ozo-resource-origin
Title: "OZO Resource Origin"
Description: "Device that originally created the resource"
* value[x] only string
* valueString 1..1
* valueString ^short = "Device origin identifier"
* valueString ^definition = "Identifier of the device that originally created the resource"

// ValueSets
ValueSet: OZOAuditEventTypeVS
Id: ozo-auditevent-type-vs
Title: "OZO AuditEvent Type ValueSet"
Description: "Types of audit events for OZO"
* ^status = #active
* http://terminology.hl7.org/CodeSystem/audit-event-type#rest "RESTful Operation"
* http://terminology.hl7.org/CodeSystem/iso-21089-lifecycle#transmit "Transmit Record Lifecycle Event"

ValueSet: OZOAuditEventSubtypeVS
Id: ozo-auditevent-subtype-vs
Title: "OZO AuditEvent Subtype ValueSet"
Description: "Subtypes of audit events for OZO"
* ^status = #active
* http://hl7.org/fhir/restful-interaction#read "read"
* http://hl7.org/fhir/restful-interaction#vread "vread"
* http://hl7.org/fhir/restful-interaction#update "update"
* http://hl7.org/fhir/restful-interaction#patch "patch"
* http://hl7.org/fhir/restful-interaction#delete "delete"
* http://hl7.org/fhir/restful-interaction#history "history"
* http://hl7.org/fhir/restful-interaction#create "create"
* http://hl7.org/fhir/restful-interaction#search "search"
* http://hl7.org/fhir/restful-interaction#capabilities "capabilities"
* http://hl7.org/fhir/restful-interaction#batch "batch"
* http://hl7.org/fhir/restful-interaction#transaction "transaction"
* http://hl7.org/fhir/restful-interaction#operation "operation"

ValueSet: OZOAuditEventAgentTypeVS
Id: ozo-auditevent-agent-type-vs
Title: "OZO AuditEvent Agent Type ValueSet"
Description: "Types of agents in OZO audit events"
* ^status = #active
* http://dicom.nema.org/resources/ontology/DCM#110150 "Application"
* http://dicom.nema.org/resources/ontology/DCM#110151 "Application Launcher"
* http://dicom.nema.org/resources/ontology/DCM#110152 "Destination Role ID"
* http://dicom.nema.org/resources/ontology/DCM#110153 "Source Role ID"

ValueSet: OZOAuditEventSourceTypeVS
Id: ozo-auditevent-source-type-vs
Title: "OZO AuditEvent Source Type ValueSet"
Description: "Types of sources in OZO audit events"
* ^status = #active
* http://terminology.hl7.org/CodeSystem/security-source-type#4 "Application Server"

ValueSet: OZOAuditEventEntityTypeVS
Id: ozo-auditevent-entity-type-vs
Title: "OZO AuditEvent Entity Type ValueSet"
Description: "Types of entities in OZO audit events"
* ^status = #active
* http://terminology.hl7.org/CodeSystem/audit-entity-type#2 "System Object"
* http://hl7.org/fhir/resource-types#Patient "Patient"
* http://hl7.org/fhir/resource-types#Practitioner "Practitioner"
* http://hl7.org/fhir/resource-types#RelatedPerson "RelatedPerson"
* http://hl7.org/fhir/resource-types#Organization "Organization"
* http://hl7.org/fhir/resource-types#CareTeam "CareTeam"
* http://hl7.org/fhir/resource-types#Task "Task"
* http://hl7.org/fhir/resource-types#Communication "Communication"
* http://hl7.org/fhir/resource-types#CommunicationRequest "CommunicationRequest"
* http://hl7.org/fhir/resource-types#Observation "Observation"
* http://hl7.org/fhir/resource-types#Encounter "Encounter"