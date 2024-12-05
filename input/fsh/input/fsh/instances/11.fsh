Instance: 11
InstanceOf: CommunicationRequest
Usage: #example
* meta.versionId = "1"
* meta.lastUpdated = "2024-12-05T16:24:58.341+00:00"
* meta.source = "#uOG9GfeYXfVhTJFw"
* status = #draft
* subject = Reference(5) "H. de Boer"
* subject.type = "Patient"
* payload[0].contentString = "Thread created by RelatedPerson"
* payload[+].contentAttachment.contentType = #application/pdf
* payload[=].contentAttachment.url = "https://example.com/data/rapport_fractuur.pdf"
* payload[=].contentAttachment.title = "rapport_fractuur.pdf"
* payload[=].contentAttachment.creation = "3899-06-21T00:00:00+02:00"
* requester = Reference(6)
* requester.type = "RelatedPerson"
* recipient = Reference(10)
* recipient.type = "CareTeam"