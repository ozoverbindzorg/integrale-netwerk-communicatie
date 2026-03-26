Instance: Clinic-Response-to-Pharmacy
InstanceOf: OZOCommunication
Usage: #example
Title: "Team Messaging: Clinic Response"
Description: "First reply in the team thread. A practitioner from the clinic responds to the pharmacy's CommunicationRequest. The sender is the individual (for auditability) while the recipient is the pharmacy CareTeam (read from CommunicationRequest.extension[senderCareTeam] for reply-to address)."
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication"
* meta.versionId = "1"
* meta.lastUpdated = "2025-12-04T10:30:00.000+00:00"
* partOf = Reference(Pharmacy-to-Clinic)
* partOf.type = "CommunicationRequest"
* status = #completed
* sender = Reference(Manu-van-Weel)
* sender.type = "Practitioner"
* sender.display = "Manu van Weel"
* recipient = Reference(Pharmacy-A)
* recipient.type = "CareTeam"
* recipient.display = "Apotheek de Pil - Team"
* payload.contentString = "Dank voor het bericht. Ik heb de medicatielijst bekeken en zie geen directe interacties met de huidige medicatie. Wel adviseer ik om de INR-waarden de eerste weken extra te monitoren. Ik stuur vandaag nog een uitgebreider advies."
