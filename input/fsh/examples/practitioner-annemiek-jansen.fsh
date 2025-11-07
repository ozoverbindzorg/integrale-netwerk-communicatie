Instance: Practitioner-Annemiek-Jansen
InstanceOf: OZOPractitioner
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* id = "1210"
* meta.versionId = "1"
* meta.lastUpdated = "2025-06-19T10:16:00.000+00:00"
* identifier[ozoProfessionalId].system = "OZO-CONNECT/Professional"
* identifier[ozoProfessionalId].value = "1141"
* identifier[email].system = "email"
* identifier[email].value = "a.jansen@thuiszorg.nl"
* name.text = "Annemiek Jansen"
* name.given = "Annemiek"
* name.family = "Jansen"
* name.family.extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
* name.family.extension.valueString = "Jansen"
* qualification.code.coding.system = "http://terminology.hl7.org/CodeSystem/v2-0360"
* qualification.code.coding.code = #RN
* qualification.code.coding.display = "Registered Nurse"
* qualification.code.text = "Verpleegkundige"
* active = true