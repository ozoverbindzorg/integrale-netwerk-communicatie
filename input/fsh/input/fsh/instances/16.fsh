Instance: 16
InstanceOf: AuditEvent
Usage: #example
* meta.versionId = "1"
* meta.lastUpdated = "2024-11-27T18:00:46.714+00:00"
* meta.source = "#ts8rOO19AlekWUW8"
* type = $iso-21089-lifecycle#access
* action = #R
* recorded = "2024-11-27T19:00:46.680+01:00"
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