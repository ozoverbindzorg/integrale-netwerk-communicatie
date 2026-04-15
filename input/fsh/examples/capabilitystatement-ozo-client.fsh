Instance: OZO-Client
InstanceOf: CapabilityStatement
Usage: #definition
Title: "OZO Client CapabilityStatement"
Description: "CapabilityStatement for authenticated client access to the OZO FHIR API. Covers Practitioner, RelatedPerson, and Patient roles. All three roles have the same resource types and interactions available — the AAA proxy scopes access differently per role by automatically applying search filters based on the caller's credentials. See the CapabilityStatements documentation page for per-role filtering details."
* url = "http://ozoverbindzorg.nl/fhir/CapabilityStatement/OZO-Client"
* version = "0.7.8"
* name = "OZOClientCapabilityStatement"
* title = "OZO Client CapabilityStatement"
* status = #active
* experimental = false
* date = "2026-03-27"
* publisher = "Headease"
* contact.name = "Headease"
* contact.telecom.system = #url
* contact.telecom.value = "https://headease.nl"
* description = "Authenticated client access to the OZO FHIR API for Practitioner, RelatedPerson, and Patient roles. All three roles share the same interactions — the AAA proxy transparently scopes access by rewriting search queries based on the caller's credentials and CareTeam memberships. Write operations validate that the sender/requester is the authenticated user."
* kind = #instance
* fhirVersion = #4.0.1
* format[0] = #json
* format[+] = #xml

* rest.mode = #server
* rest.documentation = "Client access for Practitioner, RelatedPerson, and Patient roles. The AAA proxy automatically filters all search results based on the caller's identity and CareTeam memberships. Write operations validate that the sender/requester is the authenticated user. See the CapabilityStatements documentation page for per-role scoping details."

// Patient — read only
* rest.resource[0].type = #Patient
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPatient"
* rest.resource[=].documentation = "Proxy auto-scopes to patients within the caller's CareTeam context."
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// Practitioner — read only
* rest.resource[+].type = #Practitioner
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* rest.resource[=].documentation = "Proxy auto-scopes to practitioners within the caller's CareTeam context."
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// RelatedPerson — read only
* rest.resource[+].type = #RelatedPerson
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson"
* rest.resource[=].documentation = "Proxy auto-scopes to related persons within the caller's CareTeam context."
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// CareTeam — read only
* rest.resource[+].type = #CareTeam
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCareTeam"
* rest.resource[=].documentation = "Proxy auto-scopes to CareTeams where the caller is a participant or subject."
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// CommunicationRequest — read + create
* rest.resource[+].type = #CommunicationRequest
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunicationRequest"
* rest.resource[=].documentation = "Threads where the caller or their CareTeam is a recipient. Create requires requester = authenticated user."
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create

// Communication — read + create
* rest.resource[+].type = #Communication
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication"
* rest.resource[=].documentation = "Messages in threads accessible to the caller. Create requires sender = authenticated user."
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create

// Task — read only
* rest.resource[+].type = #Task
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask"
* rest.resource[=].documentation = "Tasks owned by or assigned to the caller. Used as read/unread indicator."
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// AuditEvent — read + create
* rest.resource[+].type = #AuditEvent
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOAuditEvent"
* rest.resource[=].documentation = "Audit events within the caller's access scope. Create requires agent[requestor=true].who = authenticated user."
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create

// Subscription — read, create, update
* rest.resource[+].type = #Subscription
* rest.resource[=].documentation = "Subscriptions with criteria automatically rewritten by the proxy to scope to the caller's access. Uses notify-then-pull pattern (empty payload)."
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #update
