Instance: Notify-Mark-Benson
InstanceOf: OZOTask
Usage: #example
Title: "Task: Unread indicator for Mark Benson"
Description: "Task tracking unread message status for Practitioner Mark Benson in the Thread-Example thread. Status is 'requested' (unread) when created by the OZO FHIR Api after a new message arrives. Changes to 'completed' when the message is read."
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask"
* meta.versionId = "1"
* meta.lastUpdated = "2024-12-05T16:25:00.631+00:00"
* basedOn = Reference(Thread-Example)
* status = #requested
* intent = #order
* for = Reference(H-de-Boer) "H. de Boer"
* for.type = "Patient"
* owner = Reference(Mark-Benson)