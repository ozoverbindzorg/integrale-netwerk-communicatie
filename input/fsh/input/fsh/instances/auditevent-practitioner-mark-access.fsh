Instance: AuditEvent-Practitioner-Mark-Access
InstanceOf: OZOAuditEvent
Usage: #example
Title: "AuditEvent - Practitioner Mark Access"
Description: "Example of an AuditEvent for Practitioner Mark Benson accessing Communication resources"
* meta.versionId = "1"
* meta.lastUpdated = "2024-12-05T16:25:00.608+00:00"
* meta.source = "#vosr9Nat7LLHv1yY"
* type = http://terminology.hl7.org/CodeSystem/audit-event-type#rest "RESTful Operation"
* subtype = http://hl7.org/fhir/restful-interaction#read "read"
* action = #R
* recorded = "2024-12-05T17:25:00.605+01:00"
* outcome = #0
* agent[0].type = http://dicom.nema.org/resources/ontology/DCM#110153 "Source Role ID"
* agent[=].who = Reference(Practitioner-Mark-Benson) "Mark Benson"
* agent[=].who.type = "Practitioner"
* agent[=].requestor = true
* source.site = "OZO platform"
* source.observer = Reference(Device/ozo-aaa-proxy-001) "AAA Proxy Instance 001"
* source.observer.type = "Device"
* source.type = http://terminology.hl7.org/CodeSystem/security-source-type#4 "Application Server"
* entity[0].what = Reference(CommunicationRequest-Thread-Example)
* entity[=].what.type = "CommunicationRequest"
* entity[=].type = http://hl7.org/fhir/resource-types#CommunicationRequest "CommunicationRequest"
* entity[=].role = http://terminology.hl7.org/CodeSystem/object-role#4 "Domain Resource"
* entity[+].what = Reference(Communication-RelatedPerson-to-CareTeam)
* entity[=].what.type = "Communication"
* entity[=].type = http://hl7.org/fhir/resource-types#Communication "Communication"
* entity[=].role = http://terminology.hl7.org/CodeSystem/object-role#4 "Domain Resource"
* extension[traceId].valueString = "4af7651916cd43dd8448eb211c80319c"
* extension[spanId].valueString = "f7ad6b7169203331"