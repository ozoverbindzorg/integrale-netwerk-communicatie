Instance: AuditEvent-Practitioner-Manu-Access
InstanceOf: AuditEvent
Usage: #example
* meta.versionId = "1"
* meta.lastUpdated = "2024-12-05T16:25:00.051+00:00"
* meta.source = "#aBcgLZWzFcBhvddl"
* type = $iso-21089-lifecycle#access
* action = #R
* recorded = "2024-12-05T17:25:00.042+01:00"
* agent.who = Reference(Practitioner-Manu-van-Weel) "Manu van Weel"
* agent.who.type = "Practitioner"
* agent.requestor = true
* source.site = "OZO platform"
* source.observer = Reference(Practitioner-Manu-van-Weel) "Manu van Weel"
* source.observer.type = "Practitioner"
* entity[0].what = Reference(CommunicationRequest-Thread-Example)
* entity[=].what.type = "CommunicationRequest"
* entity[+].what = Reference(Communication-RelatedPerson-to-CareTeam)
* entity[=].what.type = "Communication"