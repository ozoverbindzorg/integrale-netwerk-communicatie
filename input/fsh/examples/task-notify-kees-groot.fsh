Instance: Notify-Kees-Groot
InstanceOf: OZOTask
Usage: #example
Title: "Task: Unread indicator for Kees Groot"
Description: "Task tracking unread message status for RelatedPerson Kees Groot in the Thread-Example thread. Status is 'requested' (unread) when created by the OZO FHIR Api after a new message arrives. Changes to 'completed' when the message is read (via AuditEvent)."
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask"
* meta.versionId = "1"
* meta.lastUpdated = "2024-12-05T16:25:01.748+00:00"
* basedOn = Reference(Thread-Example)
* status = #requested
* intent = #order
* for = Reference(H-de-Boer) "H. de Boer"
* for.type = "Patient"
* owner = Reference(Kees-Groot)