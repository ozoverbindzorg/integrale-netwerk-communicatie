Instance: OZO-RelatedPerson
InstanceOf: CapabilityStatement
Usage: #definition
Title: "OZO RelatedPerson CapabilityStatement"
Description: "CapabilityStatement for related person (informal caregiver) access to the OZO FHIR API. Access is scoped to the related person's own profile and resources within their CareTeam memberships. The AAA proxy automatically applies search filters."
* url = "http://ozoverbindzorg.nl/fhir/CapabilityStatement/OZO-RelatedPerson"
* version = "0.6.0"
* name = "OZORelatedPersonCapabilityStatement"
* title = "OZO RelatedPerson CapabilityStatement"
* status = #active
* experimental = false
* date = "2026-03-27"
* publisher = "Headease"
* contact.name = "Headease"
* contact.telecom.system = #url
* contact.telecom.value = "https://headease.nl"
* description = "RelatedPerson (informal caregiver) access to the OZO FHIR API. Authenticated via OzoUserCredential (Nuts VC). All read access is scoped to the related person's own profile and CareTeam memberships. Write access is limited to Communication, CommunicationRequest, AuditEvent, and Subscription. The sender/requester must be the authenticated related person."
* kind = #instance
* fhirVersion = #4.0.1
* format[0] = #json
* format[+] = #xml

* rest.mode = #server
* rest.documentation = "RelatedPerson (informal caregiver) access. The AAA proxy filters all search results to resources within the related person's CareTeam memberships. Write operations validate that the sender/requester is the authenticated related person."

// Patient — read only, filtered by RelatedPerson.patient
* rest.resource[0].type = #Patient
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPatient"
* rest.resource[=].documentation = "Patients that this related person is linked to. Proxy auto-applies: `_has:RelatedPerson:patient:identifier={relatedPerson}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// Practitioner — read only, filtered by shared CareTeam
* rest.resource[+].type = #Practitioner
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* rest.resource[=].documentation = "Practitioners in CareTeams shared with the related person. Proxy auto-applies: `_has:CareTeam:participant:participant={relatedPerson}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// RelatedPerson — read only, own profile
* rest.resource[+].type = #RelatedPerson
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson"
* rest.resource[=].documentation = "Only the authenticated related person's own profile. Proxy auto-applies: `identifier={relatedPerson}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// CareTeam — read only, filtered by participation
* rest.resource[+].type = #CareTeam
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCareTeam"
* rest.resource[=].documentation = "CareTeams where the related person is a participant. Proxy auto-applies: `participant={relatedPerson}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// CommunicationRequest — read + create, filtered by recipient
* rest.resource[+].type = #CommunicationRequest
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunicationRequest"
* rest.resource[=].documentation = "Threads where the related person or their CareTeam is a recipient. Create requires requester = authenticated related person. Proxy auto-applies: `recipient={relatedPerson OR careTeams}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create

// Communication — read + create, filtered via CommunicationRequest
* rest.resource[+].type = #Communication
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication"
* rest.resource[=].documentation = "Messages in threads accessible to the related person. Create requires sender = authenticated related person. Proxy auto-applies: `part-of:CommunicationRequest.recipient={relatedPerson OR careTeams}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create

// Task — read only, filtered by ownership
* rest.resource[+].type = #Task
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask"
* rest.resource[=].documentation = "Tasks owned by the related person. Proxy auto-applies: `owner={relatedPerson}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type

// AuditEvent — read + create, filtered by agent
* rest.resource[+].type = #AuditEvent
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOAuditEvent"
* rest.resource[=].documentation = "Audit events where the related person or their CareTeam is the agent. Create requires agent[requestor=true].who = authenticated related person. Proxy auto-applies: `agent={relatedPerson OR careTeams}`"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create

// Subscription — full CRUD, criteria rewritten by proxy
* rest.resource[+].type = #Subscription
* rest.resource[=].documentation = "Subscriptions with criteria automatically rewritten by the proxy to scope results to the related person's access. Uses notify-then-pull pattern (empty payload)."
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #update
