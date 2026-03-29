Instance: Annemiek-Jansen
InstanceOf: OZOPractitioner
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* meta.versionId = "1"
* meta.lastUpdated = "2025-06-19T10:16:00.000+00:00"
* identifier[0].system = "https://www.ozoverbindzorg.nl/namingsystem/professional"
* identifier[0].value = "practitioner-annemiek-jansen"
* identifier[0].assigner.identifier.type.coding.system = $provenance-participant-type
* identifier[0].assigner.identifier.type.coding.code = #author
* identifier[0].assigner.identifier.system = $ura
* identifier[0].assigner.identifier.value = "23123123123"
* identifier[+].system = "https://www.ozoverbindzorg.nl/namingsystem/professional"
* identifier[=].value = "1141"
* identifier[+].system = "https://www.ozoverbindzorg.nl/namingsystem/email"
* identifier[=].value = "a.jansen@thuiszorg.nl"
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
