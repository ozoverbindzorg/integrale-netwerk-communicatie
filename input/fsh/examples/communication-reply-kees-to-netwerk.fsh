Instance: Reply-Kees-to-Netwerk
InstanceOf: OZOCommunication
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication"
* meta.versionId = "1"
* meta.lastUpdated = "2024-12-05T16:24:59.480+00:00"
* meta.source = "#WrQmGkFS9t2VMX1A"
* partOf = Reference(Thread-Example)
* partOf.type = "CommunicationRequest"
* status = #in-progress
* recipient = Reference(Netwerk-H-de-Boer)
* recipient.type = "CareTeam"
* sender = Reference(Kees-Groot)
* sender.type = "RelatedPerson"
* payload.contentString = "Message from RelatedPerson to CareTeam"