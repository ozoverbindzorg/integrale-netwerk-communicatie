Instance: Task-Practitioner-Manu-Example
InstanceOf: OZOTask
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask"
* meta.versionId = "2"
* meta.lastUpdated = "2024-12-05T16:25:00.081+00:00"
* meta.source = "#JUZrXHNIP4pY4wNR"
* basedOn = Reference(CommunicationRequest-Thread-Example)
* status = #completed
* intent = #order
* for = Reference(Patient-H-de-Boer) "H. de Boer"
* for.type = "Patient"
* owner = Reference(Practitioner-Manu-van-Weel)