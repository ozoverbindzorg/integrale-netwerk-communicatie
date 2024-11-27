Instance: 16
InstanceOf: AuditEvent
Usage: #example
* meta.versionId = "1"
* meta.lastUpdated = "2024-11-27T22:04:46.038+00:00"
* meta.source = "#NTxZiBoQy4zSzbKq"
* type = $iso-21089-lifecycle#access
* action = #R
* recorded = "2024-11-27T23:04:45.939+01:00"
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