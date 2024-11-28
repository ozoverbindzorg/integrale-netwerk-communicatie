Instance: 16
InstanceOf: AuditEvent
Usage: #example
* meta.versionId = "1"
* meta.lastUpdated = "2024-11-28T00:23:37.720+00:00"
* meta.source = "#WKe2UsRT1Q81Dql4"
* type = $iso-21089-lifecycle#access
* action = #R
* recorded = "2024-11-28T01:23:37.706+01:00"
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