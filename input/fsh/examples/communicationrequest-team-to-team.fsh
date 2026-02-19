Instance: Pharmacy-to-Clinic
InstanceOf: OZOCommunicationRequest
Usage: #example
Title: "Team-to-Team CommunicationRequest: Pharmacy to Clinic"
Description: "Example of a team-to-team CommunicationRequest where a pharmacy sends a message to a clinic. The senderCareTeam extension specifies the pharmacy team as the reply-to address for team-level authorization. The requester is the individual practitioner who initiated the thread for auditability."
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunicationRequest"
* meta.versionId = "1"
* meta.lastUpdated = "2025-12-04T09:00:00.000+00:00"
* status = #active
* subject = Reference(H-de-Boer) "H. de Boer"
* subject.type = "Patient"
* requester = Reference(A-P-Otheeker)
* requester.type = "Practitioner"
* extension[senderCareTeam].valueReference = Reference(CT-Pharmacy-A)
* recipient = Reference(CT-Clinic-B)
* recipient.type = "CareTeam"
* payload[0].contentString = "Beste collega's, kunnen jullie de medicatielijst van deze patiënt controleren op mogelijke interacties? We hebben een nieuw recept ontvangen voor bloedverdunners."
