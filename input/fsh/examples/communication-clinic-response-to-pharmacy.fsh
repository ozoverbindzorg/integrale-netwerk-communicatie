Instance: Clinic-Response-to-Pharmacy
InstanceOf: OZOCommunication
Usage: #example
Title: "Team Messaging: Clinic Response"
Description: "First reply in the team thread. A practitioner from the clinic responds to the pharmacy's CommunicationRequest. The sender is the individual (for auditability). Thread participants are defined on CommunicationRequest.recipient."
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication"
* meta.versionId = "1"
* meta.lastUpdated = "2025-12-04T10:30:00.000+00:00"
* partOf = Reference(Pharmacy-to-Clinic)
* partOf.type = "CommunicationRequest"
* status = #completed
* sender = Reference(Manu-van-Weel)
* sender.type = "Practitioner"
* sender.display = "Manu van Weel"
* payload.contentString = "Dank voor het bericht. Ik heb de medicatielijst bekeken en zie geen directe interacties met de huidige medicatie. Wel adviseer ik om de INR-waarden de eerste weken extra te monitoren. Ik stuur vandaag nog een uitgebreider advies."
