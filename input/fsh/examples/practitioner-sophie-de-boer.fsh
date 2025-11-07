Instance: Practitioner-Sophie-de-Boer
InstanceOf: OZOPractitioner
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* id = "1220"
* meta.versionId = "1"
* meta.lastUpdated = "2025-06-19T11:01:00.000+00:00"
* identifier[ozoProfessionalId].system = "OZO-CONNECT/Professional"
* identifier[ozoProfessionalId].value = "1150"
* identifier[email].system = "email"
* identifier[email].value = "s.deboer@thuiszorg.nl"
* name.text = "Sophie de Boer"
* name.given = "Sophie"
* name.family = "de Boer"
* name.family.extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
* name.family.extension.valueString = "de Boer"
* qualification.code.coding.system = "http://terminology.hl7.org/CodeSystem/v2-0360"
* qualification.code.coding.code = #RN
* qualification.code.coding.display = "Registered Nurse"
* qualification.code.text = "Verpleegkundige"
* active = true