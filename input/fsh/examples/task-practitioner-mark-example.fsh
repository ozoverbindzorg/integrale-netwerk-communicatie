Instance: Task-Practitioner-Mark-Example
InstanceOf: OZOTask
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask"
* meta.versionId = "2"
* meta.lastUpdated = "2024-12-05T16:25:00.631+00:00"
* meta.source = "#L2oJn1KICxCdjqYq"
* basedOn = Reference(CommunicationRequest-Thread-Example)
* status = #completed
* intent = #order
* for = Reference(Patient-H-de-Boer) "H. de Boer"
* for.type = "Patient"
* owner = Reference(Practitioner-Mark-Benson)