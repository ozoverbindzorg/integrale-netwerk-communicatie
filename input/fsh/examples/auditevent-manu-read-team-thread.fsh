Instance: Manu-Read-Team-Thread
InstanceOf: OZOAuditEvent
Usage: #example
Title: "AuditEvent - Read receipt by Manu van Weel on behalf of Clinic B"
Description: "Read receipt in a team thread. Practitioner Manu van Weel opens the Pharmacy-to-Clinic thread in the OZO platform. agent.who is the individual who read (NEN7510 attribution); agent.extension[careTeam] names the organizational team on whose behalf the message was read, Clinic B. The OZO FHIR Api completes the Task owned by Clinic B. The thread has no Communication yet (the initial message is the CommunicationRequest payload), so the receipt carries the CommunicationRequest entity only."
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOAuditEvent"
* meta.versionId = "1"
* meta.lastUpdated = "2025-12-04T10:15:00.051+00:00"
* type = $iso-21089-lifecycle#access "Access/View Record Lifecycle Event"
* action = #R
* recorded = "2025-12-04T11:15:00.042+01:00"
* outcome = #0
* agent[0].type = http://dicom.nema.org/resources/ontology/DCM#110153 "Source Role ID"
* agent[=].who = Reference(Manu-van-Weel) "Manu van Weel"
* agent[=].who.type = "Practitioner"
* agent[=].requestor = true
* agent[=].extension[careTeam].valueReference = Reference(Clinic-B) "Huisarts Amsterdam - Team"
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
* extension[traceId].valueString = "6af7651916cd43dd8448eb211c80319c"
* extension[spanId].valueString = "27ad6b7169203331"
