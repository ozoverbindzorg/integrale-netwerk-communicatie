Instance: Pieter-Read-Team-Thread
InstanceOf: OZOAuditEvent
Usage: #example
Title: "AuditEvent - Read receipt by Pieter de Vries on behalf of Pharmacy A"
Description: "Read receipt in a team thread. Practitioner Pieter de Vries reads the clinic's reply in the Pharmacy-to-Clinic thread. agent.who is the individual who read; agent.extension[careTeam] names Pharmacy A, the team on whose behalf the message was read. The receipt carries two entity entries: the CommunicationRequest (required, the OZO FHIR Api finds the team Task through it) and the Communication that was viewed (optional but recommended; the Task is only completed when this is the newest message in the thread). The OZO FHIR Api completes the Task owned by Pharmacy A."
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOAuditEvent"
* meta.versionId = "1"
* meta.lastUpdated = "2025-12-04T11:05:00.051+00:00"
* type = $iso-21089-lifecycle#access "Access/View Record Lifecycle Event"
* action = #R
* recorded = "2025-12-04T12:05:00.042+01:00"
* outcome = #0
* agent[0].type = http://dicom.nema.org/resources/ontology/DCM#110153 "Source Role ID"
* agent[=].who = Reference(Pieter-de-Vries) "Pieter de Vries"
* agent[=].who.type = "Practitioner"
* agent[=].requestor = true
* agent[=].extension[careTeam].valueReference = Reference(Pharmacy-A) "Apotheek de Pil - Team"
* source.site = "OZO platform"
* source.observer.identifier.system = "https://www.ozoverbindzorg.nl/namingsystem/device"
* source.observer.identifier.value = "aaa-proxy-001"
* source.observer.display = "AAA Proxy Instance 001"
* source.observer.type = "Device"
* source.type = http://terminology.hl7.org/CodeSystem/security-source-type#4 "Application Server"
* entity[0].what.reference = "CommunicationRequest/Pharmacy-to-Clinic/_history/1"
* entity[=].what.type = "CommunicationRequest"
* entity[=].type = http://hl7.org/fhir/resource-types#CommunicationRequest "CommunicationRequest"
* entity[=].role = http://terminology.hl7.org/CodeSystem/object-role#4 "Domain Resource"
* entity[+].what.reference = "Communication/Clinic-Response-to-Pharmacy/_history/1"
* entity[=].what.type = "Communication"
* entity[=].type = http://hl7.org/fhir/resource-types#Communication "Communication"
* entity[=].role = http://terminology.hl7.org/CodeSystem/object-role#4 "Domain Resource"
* extension[traceId].valueString = "7af7651916cd43dd8448eb211c80319c"
* extension[spanId].valueString = "37ad6b7169203331"
