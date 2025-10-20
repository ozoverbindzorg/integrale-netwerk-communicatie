Instance: Communication-RelatedPerson-to-CareTeam
InstanceOf: Communication
Usage: #example
* meta.versionId = "1"
* meta.lastUpdated = "2024-12-05T16:24:59.480+00:00"
* meta.source = "#WrQmGkFS9t2VMX1A"
* partOf = Reference(CommunicationRequest-Thread-Example)
* partOf.type = "CommunicationRequest"
* status = #in-progress
* recipient = Reference(CareTeam-H-de-Boer)
* recipient.type = "CareTeam"
* sender = Reference(RelatedPerson-Kees-Groot)
* sender.type = "RelatedPerson"
* payload.contentString = "Message from RelatedPerson to CareTeam"