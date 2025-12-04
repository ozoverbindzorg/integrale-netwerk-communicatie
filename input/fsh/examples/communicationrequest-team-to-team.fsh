Instance: CommunicationRequest-Pharmacy-to-Clinic
InstanceOf: OZOCommunicationRequest
Usage: #example
Title: "Team-to-Team CommunicationRequest: Pharmacy to Clinic"
Description: "Example of a team-to-team CommunicationRequest where a pharmacy sends a message to a clinic. The sender is a CareTeam (pharmacy team) which enables team-level authorization and provides the reply-to address. The requester is the individual practitioner who initiated the thread for auditability."
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunicationRequest"
* meta.versionId = "1"
* meta.lastUpdated = "2025-12-04T09:00:00.000+00:00"
* status = #active
* subject = Reference(Patient-H-de-Boer) "H. de Boer"
* subject.type = "Patient"
* requester = Reference(Practitioner-A-P-Otheeker)
* requester.type = "Practitioner"
* sender = Reference(CareTeam-Pharmacy-A)
* sender.type = "CareTeam"
* recipient = Reference(CareTeam-Clinic-B)
* recipient.type = "CareTeam"
* payload[0].contentString = "Beste collega's, kunnen jullie de medicatielijst van deze patiënt controleren op mogelijke interacties? We hebben een nieuw recept ontvangen voor bloedverdunners."
