Instance: Notify-Clinic-B
InstanceOf: OZOTask
Usage: #example
Title: "Task: Team inbox state for Clinic B"
Description: "Task holding the read state of the organizational team Clinic B in the Pharmacy-to-Clinic thread. The OZO FHIR Api creates one Task per organizational team that is a party of a team thread, with owner set to the CareTeam. Status is 'requested' (unread for the team) when the thread is created by the other team. It changes to 'completed' when a member of Clinic B sends a read receipt or a reply that names Clinic B in the agent or sender extension. Every member of Clinic B sees this Task; a member of two teams in the same thread sees two Tasks."
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask"
* meta.versionId = "1"
* meta.lastUpdated = "2025-12-04T09:00:01.000+00:00"
* basedOn = Reference(Pharmacy-to-Clinic)
* status = #requested
* intent = #order
* for = Reference(H-de-Boer) "H. de Boer"
* for.type = "Patient"
* owner = Reference(Clinic-B) "Huisarts Amsterdam - Team"
* owner.type = "CareTeam"
