Instance: Communication-Team-Reply-2-Clinic-Response
InstanceOf: OZOCommunication
Usage: #example
Title: "Team Messaging: Clinic Response"
Description: "Reply from the clinic to the pharmacy. A practitioner from the clinic responds - the sender is the individual (for auditability) while the recipient is the pharmacy CareTeam (read from CommunicationRequest.sender for reply-to address)."
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication"
* meta.versionId = "1"
* meta.lastUpdated = "2025-12-04T10:30:00.000+00:00"
* partOf = Reference(CommunicationRequest-Pharmacy-to-Clinic)
* partOf.type = "CommunicationRequest"
* inResponseTo = Reference(Communication-Team-Reply-1-Initial-Message)
* inResponseTo.type = "Communication"
* status = #completed
* sender = Reference(Practitioner-Manu-van-Weel)
* sender.type = "Practitioner"
* sender.display = "Manu van Weel"
* recipient = Reference(CareTeam-Pharmacy-A)
* recipient.type = "CareTeam"
* recipient.display = "Apotheek de Pil - Team"
* payload.contentString = "Dank voor het bericht. Ik heb de medicatielijst bekeken en zie geen directe interacties met de huidige medicatie. Wel adviseer ik om de INR-waarden de eerste weken extra te monitoren. Ik stuur vandaag nog een uitgebreider advies."
