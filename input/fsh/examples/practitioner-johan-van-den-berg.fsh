Instance: Practitioner-Johan-van-den-Berg
InstanceOf: OZOPractitioner
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* id = "1211"
* meta.versionId = "1"
* meta.lastUpdated = "2025-06-19T10:17:00.000+00:00"
* identifier[ozoProfessionalId].system = "OZO-CONNECT/Professional"
* identifier[ozoProfessionalId].value = "1142"
* identifier[email].system = "email"
* identifier[email].value = "j.vandenberg@fysiotherapie.nl"
* name.text = "Johan van den Berg"
* name.given = "Johan"
* name.family = "van den Berg"
* name.family.extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
* name.family.extension.valueString = "van den Berg"
* qualification.code.coding.system = "http://snomed.info/sct"
* qualification.code.coding.code = #36682004
* qualification.code.coding.display = "Physiotherapist"
* qualification.code.text = "Fysiotherapeut"
* active = true