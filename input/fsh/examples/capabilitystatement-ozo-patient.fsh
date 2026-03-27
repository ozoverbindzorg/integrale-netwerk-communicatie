Instance: OZO-Patient
InstanceOf: CapabilityStatement
Usage: #definition
Title: "OZO Patient CapabilityStatement"
Description: "CapabilityStatement for patient self-service access to the OZO FHIR API. Access is scoped to the patient's own record and resources within their CareTeam memberships. The AAA proxy automatically applies search filters."
* url = "http://ozoverbindzorg.nl/fhir/CapabilityStatement/OZO-Patient"
* version = "0.6.0"
* name = "OZOPatientCapabilityStatement"
* title = "OZO Patient CapabilityStatement"
* status = #active
* experimental = false
* date = "2026-03-27"
* publisher = "Headease"
* contact.name = "Headease"
* contact.telecom.system = #url
* contact.telecom.value = "https://headease.nl"
* description = "Patient self-service access to the OZO FHIR API. All read access is scoped to the patient's own record and CareTeam memberships. Write access is limited to Communication, CommunicationRequest, AuditEvent, and Subscription. The sender/requester must be the authenticated patient."
* kind = #instance
* fhirVersion = #4.0.1
* format[0] = #json
* format[+] = #xml

* rest.mode = #server
* rest.documentation = "Patient self-service access. The AAA proxy filters all search results to the patient's own record and CareTeam memberships. Write operations validate that the sender/requester is the authenticated patient."

// Patient — read only, own record
* rest.resource[0].type = #Patient
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPatient"
* rest.resource[=].documentation = "Only the authenticated patient's own record. Proxy auto-applies: `identifier={patient}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// Practitioner — read only, filtered by CareTeam
* rest.resource[+].type = #Practitioner
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* rest.resource[=].documentation = "Practitioners in CareTeams where the patient is the subject. Proxy auto-applies: `_has:CareTeam:participant:patient={patient}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// RelatedPerson — read only, linked to patient
* rest.resource[+].type = #RelatedPerson
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson"
* rest.resource[=].documentation = "Related persons linked to the patient. Proxy auto-applies: `patient={patient}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// CareTeam — read only, patient is subject
* rest.resource[+].type = #CareTeam
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCareTeam"
* rest.resource[=].documentation = "CareTeams where the patient is the subject. Proxy auto-applies: `patient={patient}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// CommunicationRequest — read + create, filtered by recipient
* rest.resource[+].type = #CommunicationRequest
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunicationRequest"
* rest.resource[=].documentation = "Threads where the patient or their CareTeam is a recipient. Create requires requester = authenticated patient. Proxy auto-applies: `recipient={patient OR careTeams}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create

// Communication — read + create, filtered via CommunicationRequest
* rest.resource[+].type = #Communication
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication"
* rest.resource[=].documentation = "Messages in threads accessible to the patient. Create requires sender = authenticated patient. Proxy auto-applies: `part-of:CommunicationRequest.recipient={patient OR careTeams}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create

// Task — read only, filtered by patient
* rest.resource[+].type = #Task
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask"
* rest.resource[=].documentation = "Tasks for the patient. Proxy auto-applies: `patient={patient}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// AuditEvent — read + create, filtered by agent
* rest.resource[+].type = #AuditEvent
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOAuditEvent"
* rest.resource[=].documentation = "Audit events where the patient or their CareTeam is the agent. Create requires agent[requestor=true].who = authenticated patient. Proxy auto-applies: `agent={patient OR careTeams}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create

// Subscription — full CRUD, criteria rewritten by proxy
* rest.resource[+].type = #Subscription
* rest.resource[=].documentation = "Subscriptions with criteria automatically rewritten by the proxy to scope results to the patient's access. Uses notify-then-pull pattern (empty payload)."
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #update
