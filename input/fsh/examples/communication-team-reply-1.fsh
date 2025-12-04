Instance: Communication-Team-Reply-1-Initial-Message
InstanceOf: OZOCommunication
Usage: #example
Title: "Team Messaging: Initial Message from Pharmacy"
Description: "First message in the thread - the initial question from the pharmacy practitioner. The sender is the individual practitioner (for auditability) while the recipient is the clinic CareTeam (for shared inbox)."
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication"
* meta.versionId = "1"
* meta.lastUpdated = "2025-12-04T09:00:00.000+00:00"
* partOf = Reference(CommunicationRequest-Pharmacy-to-Clinic)
* partOf.type = "CommunicationRequest"
* status = #completed
* sender = Reference(Practitioner-A-P-Otheeker)
* sender.type = "Practitioner"
* sender.display = "A.P. Otheeker"
* recipient = Reference(CareTeam-Clinic-B)
* recipient.type = "CareTeam"
* recipient.display = "Huisarts Amsterdam - Team"
* payload.contentString = "Beste collega's, kunnen jullie de medicatielijst van deze patiënt controleren op mogelijke interacties? We hebben een nieuw recept ontvangen voor bloedverdunners."
