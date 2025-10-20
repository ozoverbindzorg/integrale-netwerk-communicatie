Instance: AuditEvent-System-Access
InstanceOf: OZOAuditEvent  
Usage: #example
Title: "AuditEvent - System Access"
Description: "Example of an AuditEvent for a system-to-system access through OZO AAA Proxy"
* meta.versionId = "1"
* meta.lastUpdated = "2025-01-08T10:45:00.000+01:00"
* meta.source = "#ozo-aaa-proxy"
* type = http://terminology.hl7.org/CodeSystem/audit-event-type#rest "RESTful Operation"
* subtype = http://hl7.org/fhir/restful-interaction#read "read"
* action = #R
* recorded = "2025-01-08T10:45:00.000+01:00"
* outcome = #0
* agent[0].type = http://dicom.nema.org/resources/ontology/DCM#110150 "Application"
* agent[=].who.identifier.system = "did_web"
* agent[=].who.identifier.value = "did:web:example.org:system:hospital-system-001"
* agent[=].who.display = "Hospital System 001"
* agent[=].who.type = "Device"
* agent[=].requestor = true
* source.site = "OZO AAA Proxy"
* source.observer = Reference(Device/ozo-aaa-proxy-001) "AAA Proxy Instance 001"
* source.observer.type = "Device"
* source.type = http://terminology.hl7.org/CodeSystem/security-source-type#4 "Application Server"
* entity[0].what = Reference(CareTeam/10)
* entity[=].what.type = "CareTeam"
* entity[=].type = http://hl7.org/fhir/resource-types#CareTeam "CareTeam"
* entity[=].role = http://terminology.hl7.org/CodeSystem/object-role#4 "Domain Resource"
* extension[traceId].valueString = "2af7651916cd43dd8448eb211c80319c"
* extension[spanId].valueString = "d7ad6b7169203331"