Instance: OZO-Server
InstanceOf: CapabilityStatement
Usage: #definition
Title: "OZO Server Base CapabilityStatement"
Description: "Base CapabilityStatement for the OZO FHIR API. Returned by the unauthenticated /metadata endpoint. Describes server identity, security requirements, and supported profiles. Authenticate to receive a role-specific CapabilityStatement with detailed interactions."
* url = "http://ozoverbindzorg.nl/fhir/CapabilityStatement/OZO-Server"
* version = "0.6.2"
* name = "OZOServerCapabilityStatement"
* title = "OZO Server Base CapabilityStatement"
* status = #active
* experimental = false
* date = "2026-03-27"
* publisher = "Headease"
* contact.name = "Headease"
* contact.telecom.system = #url
* contact.telecom.value = "https://headease.nl"
* description = "The OZO FHIR API provides healthcare communication services for the OZO platform, connecting care professionals with informal caregivers. This base CapabilityStatement is returned for unauthenticated requests. Authenticate with Nuts credentials to receive a role-specific CapabilityStatement detailing your permitted interactions."
* kind = #instance
* fhirVersion = #4.0.1
* format[0] = #json
* format[+] = #xml

// Security - Nuts protocol with DPoP
* rest.mode = #server
* rest.documentation = "The OZO FHIR API requires authentication via the Nuts protocol with DPoP tokens. Access is role-based: system, practitioner, related person, or patient. Each role has a specific CapabilityStatement describing permitted interactions. The proxy enforces notify-then-pull for Subscriptions (no payload in notifications) as required in Dutch healthcare."

* rest.security.cors = false
* rest.security.description = "Authentication via Nuts Verifiable Credentials with DPoP proof-of-possession tokens. mTLS required for system-to-system communication. See the Authentication and Authorization sections of this Implementation Guide for details."

// Supported resource types with profiles (no interactions — authenticate first)
* rest.resource[0].type = #Patient
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPatient"

* rest.resource[+].type = #Practitioner
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"

* rest.resource[+].type = #RelatedPerson
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson"

* rest.resource[+].type = #Organization
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOOrganization"

* rest.resource[+].type = #CareTeam
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCareTeam"
* rest.resource[=].documentation = "Patient care teams. See also OZOOrganizationalCareTeam for department/organization teams."

* rest.resource[+].type = #CommunicationRequest
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunicationRequest"

* rest.resource[+].type = #Communication
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication"

* rest.resource[+].type = #Task
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask"

* rest.resource[+].type = #AuditEvent
* rest.resource[=].profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOAuditEvent"

* rest.resource[+].type = #Subscription
* rest.resource[=].documentation = "Subscriptions use the notify-then-pull pattern: notifications contain no resource payload. The subscriber must fetch the resource after receiving the notification."
