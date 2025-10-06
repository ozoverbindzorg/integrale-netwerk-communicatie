Instance: AuditEvent-REST-Search-Example
InstanceOf: OZOAuditEvent
Usage: #example
Title: "AuditEvent - REST Search Operation"
Description: "Example of an AuditEvent for a REST search operation through OZO AAA Proxy"
* meta.versionId = "1"
* meta.lastUpdated = "2025-01-08T10:35:00.000+01:00"
* meta.source = "#ozo-aaa-proxy"
* type = http://terminology.hl7.org/CodeSystem/audit-event-type#rest "RESTful Operation"
* subtype = http://hl7.org/fhir/restful-interaction#search "search"
* action = #R
* recorded = "2025-01-08T10:35:00.000+01:00"
* outcome = #0
* agent[0].type = http://dicom.nema.org/resources/ontology/DCM#110153 "Source Role ID"
* agent[=].who = Reference(RelatedPerson-Kees-Groot) "Kees Groot"
* agent[=].who.type = "RelatedPerson"
* agent[=].requestor = true
* source.site = "OZO AAA Proxy"
* source.observer = Reference(Device/ozo-aaa-proxy-001) "AAA Proxy Instance 001"
* source.observer.type = "Device"
* source.type = http://terminology.hl7.org/CodeSystem/security-source-type#4 "Application Server"
* entity[0].type = http://terminology.hl7.org/CodeSystem/audit-entity-type#2 "System Object"
* entity[=].role = http://terminology.hl7.org/CodeSystem/object-role#24 "Query"
* entity[=].query