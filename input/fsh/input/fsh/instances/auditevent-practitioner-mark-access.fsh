Instance: AuditEvent-Practitioner-Mark-Access
InstanceOf: AuditEvent
Usage: #example
* meta.versionId = "1"
* meta.lastUpdated = "2024-12-05T16:25:00.608+00:00"
* meta.source = "#vosr9Nat7LLHv1yY"
* type = $iso-21089-lifecycle#access
* action = #R
* recorded = "2024-12-05T17:25:00.605+01:00"
* agent.who = Reference(Practitioner-Mark-Benson) "Mark Benson"
* agent.who.type = "Practitioner"
* agent.requestor = true
* source.site = "OZO platform"
* source.observer = Reference(Practitioner-Mark-Benson) "Mark Benson"
* source.observer.type = "Practitioner"
* entity[0].what = Reference(CommunicationRequest-Thread-Example)
* entity[=].what.type = "CommunicationRequest"
* entity[+].what = Reference(Communication-RelatedPerson-to-CareTeam)
* entity[=].what.type = "Communication"