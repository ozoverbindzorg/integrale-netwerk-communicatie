Instance: AuditEvent-REST-Update-Failure
InstanceOf: OZOAuditEvent
Usage: #example
Title: "AuditEvent - REST Update Operation Failure"
Description: "Example of an AuditEvent for a failed REST update operation through OZO AAA Proxy"
* meta.versionId = "1"
* meta.lastUpdated = "2025-01-08T10:40:00.000+01:00"
* meta.source = "#ozo-aaa-proxy"
* type = http://terminology.hl7.org/CodeSystem/audit-event-type#rest "RESTful Operation"
* subtype = http://hl7.org/fhir/restful-interaction#update "update"
* action = #U
* recorded = "2025-01-08T10:40:00.000+01:00"
* outcome = #4
* outcomeDesc = "HTTP 403 Forbidden - User not authorized to update this resource"
* agent[0].type = http://dicom.nema.org/resources/ontology/DCM#110153 "Source Role ID"
* agent[=].who = Reference(RelatedPerson-Kees-Groot) "Kees Groot"
* agent[=].who.type = "RelatedPerson"
* agent[=].requestor = true
* source.site = "OZO AAA Proxy"
* source.observer = Reference(Device/ozo-aaa-proxy-001) "AAA Proxy Instance 001"
* source.observer.type = "Device"
* source.type = http://terminology.hl7.org/CodeSystem/security-source-type#4 "Application Server"
* entity[0].what = Reference(Patient/5)
* entity[=].what.type = "Patient"
* entity[=].type = http://hl7.org/fhir/resource-types#Patient "Patient"
* entity[=].role = http://terminology.hl7.org/CodeSystem/object-role#4 "Domain Resource"
* extension[traceId].valueString = "1af7651916cd43dd8448eb211c80319c"
* extension[spanId].valueString = "c7ad6b7169203331"