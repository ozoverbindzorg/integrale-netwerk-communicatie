Instance: Notify-Pharmacy-A
InstanceOf: OZOTask
Usage: #example
Title: "Task: Team inbox state for Pharmacy A"
Description: "Task holding the read state of the organizational team Pharmacy A in the Pharmacy-to-Clinic thread. Pharmacy A is the initiating team (extension[senderCareTeam] of the CommunicationRequest), so its Task starts 'completed': the requester wrote the message and the team has nothing unread. It changes to 'requested' with focus set to the new Communication when the clinic team replies."
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask"
* meta.versionId = "1"
* meta.lastUpdated = "2025-12-04T09:00:01.000+00:00"
* basedOn = Reference(Pharmacy-to-Clinic)
* status = #completed
* intent = #order
* for = Reference(H-de-Boer) "H. de Boer"
* for.type = "Patient"
* owner = Reference(Pharmacy-A) "Apotheek de Pil - Team"
* owner.type = "CareTeam"
