Instance: 17
InstanceOf: AuditEvent
Usage: #example
* meta.versionId = "1"
* meta.lastUpdated = "2024-11-28T00:23:38.303+00:00"
* meta.source = "#AZp2FIDbkEErEfkq"
* type = $iso-21089-lifecycle#access
* action = #R
* recorded = "2024-11-28T01:23:38.299+01:00"
* agent.who = Reference(7) "Mark Benson"
* agent.who.type = "Practitioner"
* agent.requestor = true
* source.site = "OZO platform"
* source.observer = Reference(7) "Mark Benson"
* source.observer.type = "Practitioner"
* entity[0].what = Reference(10)
* entity[=].what.type = "CommunicationRequest"
* entity[+].what = Reference(15)
* entity[=].what.type = "Communication"