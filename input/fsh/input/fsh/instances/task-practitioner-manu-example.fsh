Instance: Task-Practitioner-Manu-Example
InstanceOf: Task
Usage: #example
* meta.versionId = "2"
* meta.lastUpdated = "2024-12-05T16:25:00.081+00:00"
* meta.source = "#JUZrXHNIP4pY4wNR"
* basedOn = Reference(CommunicationRequest-Thread-Example)
* status = #completed
* intent = #order
* for = Reference(Patient-H-de-Boer) "H. de Boer"
* for.type = "Patient"
* owner = Reference(Practitioner-Manu-van-Weel)