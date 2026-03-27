Instance: OZO-System
InstanceOf: CapabilityStatement
Usage: #definition
Title: "OZO System CapabilityStatement"
Description: "CapabilityStatement for OZO system-level access (server-to-server). Full CRUD access to all resources without access filters. Requires OzoSystemCredential via the Nuts protocol."
* url = "http://ozoverbindzorg.nl/fhir/CapabilityStatement/OZO-System"
* version = "0.6.3"
* name = "OZOSystemCapabilityStatement"
* title = "OZO System CapabilityStatement"
* status = #active
* experimental = false
* date = "2026-03-27"
* publisher = "Headease"
* contact.name = "Headease"
* contact.telecom.system = #url
* contact.telecom.value = "https://headease.nl"
* description = "System-level access to the OZO FHIR API. Authenticated via OzoSystemCredential (self-issued Nuts VC). Full read and write access to all resources without access filters. Intended for the OZO platform backend."
* kind = #instance
* fhirVersion = #4.0.1
* format[0] = #json
* format[+] = #xml

* rest.mode = #server
* rest.documentation = "System-level access with no access restrictions. All resources are available for read, search, create, and update operations."

// Patient
* rest.resource[0].type = #Patient
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPatient"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #update

// Practitioner
* rest.resource[+].type = #Practitioner
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #update

// RelatedPerson
* rest.resource[+].type = #RelatedPerson
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #update

// Organization
* rest.resource[+].type = #Organization
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOOrganization"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #update

// CareTeam
* rest.resource[+].type = #CareTeam
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCareTeam"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #update

// CommunicationRequest
* rest.resource[+].type = #CommunicationRequest
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunicationRequest"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #update

// Communication
* rest.resource[+].type = #Communication
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #update

// Task
* rest.resource[+].type = #Task
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #update

// AuditEvent
* rest.resource[+].type = #AuditEvent
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOAuditEvent"
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create

// Subscription
* rest.resource[+].type = #Subscription
* rest.resource[=].interaction[0].code = #read
* rest.resource[=].interaction[+].code = #search-type
* rest.resource[=].interaction[+].code = #create
* rest.resource[=].interaction[+].code = #update
