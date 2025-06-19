Instance: Communication-Practitioner-to-Practitioner
InstanceOf: Communication
Usage: #example
* meta.versionId = "1"
* meta.lastUpdated = "2024-12-05T16:25:01.145+00:00"
* meta.source = "#2eQJh4Y67kwAcNXr"
* partOf = Reference(CommunicationRequest-Thread-Example)
* partOf.type = "CommunicationRequest"
* status = #in-progress
* recipient = Reference(Practitioner-Manu-van-Weel) "Manu van Weel"
* recipient.type = "Practitioner"
* sender = Reference(Practitioner-Manu-van-Weel) "Manu van Weel"
* sender.type = "Practitioner"
* payload.contentString = "Message from RelatedPerson to CareTeam"