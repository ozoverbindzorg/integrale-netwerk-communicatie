Instance: AuditEvent-RelatedPerson-Access
InstanceOf: AuditEvent
Usage: #example
* meta.versionId = "1"
* meta.lastUpdated = "2024-12-05T16:25:01.725+00:00"
* meta.source = "#6SxJGqItGqiP85JR"
* type = $iso-21089-lifecycle#access
* action = #R
* recorded = "2024-12-05T17:25:01.713+01:00"
* agent.who = Reference(RelatedPerson-Kees-Groot)
* agent.who.type = "RelatedPerson"
* agent.requestor = true
* source.site = "OZO Client"
* source.observer = Reference(RelatedPerson-Kees-Groot)
* source.observer.type = "RelatedPerson"
* entity[0].what = Reference(CommunicationRequest-Thread-Example)
* entity[=].what.type = "CommunicationRequest"
* entity[+].what = Reference(Communication-Practitioner-to-Practitioner)
* entity[=].what.type = "Communication"