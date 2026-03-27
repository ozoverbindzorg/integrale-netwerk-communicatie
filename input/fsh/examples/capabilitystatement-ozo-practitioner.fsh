Instance: OZO-Practitioner
InstanceOf: CapabilityStatement
Usage: #definition
Title: "OZO Practitioner CapabilityStatement"
Description: "CapabilityStatement for practitioner access to the OZO FHIR API. Access is scoped to resources within the practitioner's CareTeam memberships. The AAA proxy automatically applies search filters to restrict results to the practitioner's care network."
* url = "http://ozoverbindzorg.nl/fhir/CapabilityStatement/OZO-Practitioner"
* version = "0.6.0"
* name = "OZOPractitionerCapabilityStatement"
* title = "OZO Practitioner CapabilityStatement"
* status = #active
* experimental = false
* date = "2026-03-27"
* publisher = "Headease"
* contact.name = "Headease"
* contact.telecom.system = #url
* contact.telecom.value = "https://headease.nl"
* description = "Practitioner access to the OZO FHIR API. Authenticated via NutsOrganizationCredential + NutsEmployeeCredential. All read access is scoped to the practitioner's CareTeam memberships — the proxy automatically appends search filters. Write access is limited to Communication, CommunicationRequest, AuditEvent, and Subscription. The sender/requester must be the authenticated practitioner."
* kind = #instance
* fhirVersion = #4.0.1
* format[0] = #json
* format[+] = #xml

* rest.mode = #server
* rest.documentation = "Practitioner access. The AAA proxy automatically filters all search results to resources within the practitioner's CareTeam memberships. Write operations validate that the sender/requester is the authenticated practitioner."

// Patient — read only, filtered by CareTeam membership
* rest.resource[0].type = #Patient
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPatient"
* rest.resource[=].documentation = "Patients in CareTeams where the practitioner is a participant. Proxy auto-applies: `_has:CareTeam:patient:participant={practitioner}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// Practitioner — read only, filtered by shared CareTeam
* rest.resource[+].type = #Practitioner
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* rest.resource[=].documentation = "Practitioners in CareTeams shared with the authenticated practitioner. Proxy auto-applies: `_has:CareTeam:participant:participant={practitioner}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// RelatedPerson — read only, filtered by shared CareTeam
* rest.resource[+].type = #RelatedPerson
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson"
* rest.resource[=].documentation = "Related persons in CareTeams shared with the practitioner. Proxy auto-applies: `_has:CareTeam:participant:participant={practitioner}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// CareTeam — read only, filtered by participation
* rest.resource[+].type = #CareTeam
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCareTeam"
* rest.resource[=].documentation = "CareTeams where the practitioner is a participant. Proxy auto-applies: `participant={practitioner}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// CommunicationRequest — read + create, filtered by recipient
* rest.resource[+].type = #CommunicationRequest
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunicationRequest"
* rest.resource[=].documentation = "Threads where the practitioner or their CareTeam is a recipient. Create requires requester = authenticated practitioner. Proxy auto-applies: `recipient={practitioner OR careTeams}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create

// Communication — read + create, filtered via CommunicationRequest
* rest.resource[+].type = #Communication
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication"
* rest.resource[=].documentation = "Messages in threads accessible to the practitioner. Create requires sender = authenticated practitioner. Proxy auto-applies: `part-of:CommunicationRequest.recipient={practitioner OR careTeams}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create

// Task — read only, filtered by ownership
* rest.resource[+].type = #Task
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask"
* rest.resource[=].documentation = "Tasks owned by the practitioner or their CareTeams. Proxy auto-applies: `owner={practitioner OR careTeams}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// AuditEvent — read + create, filtered by agent
* rest.resource[+].type = #AuditEvent
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOAuditEvent"
* rest.resource[=].documentation = "Audit events from practitioners in shared CareTeams. Create requires agent[requestor=true].who = authenticated practitioner. Proxy auto-applies: `agent={careTeamPractitioners}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create

// Subscription — full CRUD, criteria rewritten by proxy
* rest.resource[+].type = #Subscription
* rest.resource[=].documentation = "Subscriptions with criteria automatically rewritten by the proxy to scope results to the practitioner's access. Uses notify-then-pull pattern (empty payload)."
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #update
