Instance: 16
InstanceOf: AuditEvent
Usage: #example
* meta.versionId = "1"
* meta.lastUpdated = "2024-11-27T21:45:11.792+00:00"
* meta.source = "#VoMp484fOq9nRjqV"
* type = $iso-21089-lifecycle#access
* action = #R
* recorded = "2024-11-27T22:45:11.779+01:00"
* agent.who = Reference(6) "Manu van Weel"
* agent.who.type = "Practitioner"
* agent.requestor = true
* source.site = "OZO platform"
* source.observer = Reference(6) "Manu van Weel"
* source.observer.type = "Practitioner"
* entity[0].what = Reference(10)
* entity[=].what.type = "CommunicationRequest"
* entity[+].what = Reference(15)
* entity[=].what.type = "Communication"