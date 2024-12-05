Instance: 17
InstanceOf: AuditEvent
Usage: #example
* meta.versionId = "1"
* meta.lastUpdated = "2024-12-05T16:25:00.051+00:00"
* meta.source = "#aBcgLZWzFcBhvddl"
* type = $iso-21089-lifecycle#access
* action = #R
* recorded = "2024-12-05T17:25:00.042+01:00"
* agent.who = Reference(7) "Manu van Weel"
* agent.who.type = "Practitioner"
* agent.requestor = true
* source.site = "OZO platform"
* source.observer = Reference(7) "Manu van Weel"
* source.observer.type = "Practitioner"
* entity[0].what = Reference(11)
* entity[=].what.type = "CommunicationRequest"
* entity[+].what = Reference(16)
* entity[=].what.type = "Communication"