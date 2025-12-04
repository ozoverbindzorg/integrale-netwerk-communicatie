Instance: Communication-Team-Reply-3-Pharmacy-Followup
InstanceOf: OZOCommunication
Usage: #example
Title: "Team Messaging: Pharmacy Follow-up (Different Practitioner)"
Description: "Follow-up from a different practitioner at the pharmacy. This demonstrates that multiple team members can participate in the same thread. Note that the sender is a different practitioner from the original requester."
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication"
* meta.versionId = "1"
* meta.lastUpdated = "2025-12-04T11:15:00.000+00:00"
* partOf = Reference(CommunicationRequest-Pharmacy-to-Clinic)
* partOf.type = "CommunicationRequest"
* inResponseTo = Reference(Communication-Team-Reply-2-Clinic-Response)
* inResponseTo.type = "Communication"
* status = #completed
* sender = Reference(Practitioner-Pieter-de-Vries)
* sender.type = "Practitioner"
* sender.display = "Pieter de Vries"
* recipient = Reference(CareTeam-Clinic-B)
* recipient.type = "CareTeam"
* recipient.display = "Huisarts Amsterdam - Team"
* payload.contentString = "Bedankt voor de snelle reactie. Mijn collega is vandaag afwezig, maar ik neem dit over. We zullen de INR-monitoring inplannen en de patiënt informeren. Graag ontvangen we het uitgebreide advies zodra beschikbaar."
