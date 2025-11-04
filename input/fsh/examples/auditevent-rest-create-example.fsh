Instance: AuditEvent-REST-Create-Example
InstanceOf: OZOAuditEvent
Usage: #example
Title: "AuditEvent - REST Create Operation"
Description: "Example of an AuditEvent for a successful REST create operation through OZO AAA Proxy"
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOAuditEvent"
* meta.versionId = "1"
* meta.lastUpdated = "2025-01-08T10:30:00.000+01:00"
* meta.source = "#ozo-aaa-proxy"
* type = http://terminology.hl7.org/CodeSystem/audit-event-type#rest "RESTful Operation"
* subtype = http://hl7.org/fhir/restful-interaction#create "create"
* action = #C
* recorded = "2025-01-08T10:30:00.000+01:00"
* outcome = #0
* agent[0].type = http://dicom.nema.org/resources/ontology/DCM#110153 "Source Role ID"
* agent[=].who = Reference(Practitioner-Manu-van-Weel) "Manu van Weel"
* agent[=].who.type = "Practitioner"
* agent[=].requestor = true
* source.site = "OZO AAA Proxy"
* source.observer = Reference(Device/ozo-aaa-proxy-001) "AAA Proxy Instance 001"
* source.observer.type = "Device"
* source.type = http://terminology.hl7.org/CodeSystem/security-source-type#4 "Application Server"
* entity[0].what = Reference(Task/12345)
* entity[=].what.type = "Task"
* entity[=].type = http://hl7.org/fhir/resource-types#Task "Task"
* entity[=].role = http://terminology.hl7.org/CodeSystem/object-role#4 "Domain Resource"
* extension[traceId].valueString = "0af7651916cd43dd8448eb211c80319c"
* extension[spanId].valueString = "b7ad6b7169203331"