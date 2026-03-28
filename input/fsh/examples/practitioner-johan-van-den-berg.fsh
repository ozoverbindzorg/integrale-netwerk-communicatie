Instance: Johan-van-den-Berg
InstanceOf: OZOPractitioner
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* meta.versionId = "1"
* meta.lastUpdated = "2025-06-19T10:17:00.000+00:00"
* identifier[AssignedId].system = "https://www.ozoverbindzorg.nl/namingsystem/professional"
* identifier[AssignedId].value = "practitioner-johan-van-den-berg"
* identifier[AssignedId].assigner.identifier.type.coding.system = $provenance-participant-type
* identifier[AssignedId].assigner.identifier.type.coding.code = #author
* identifier[AssignedId].assigner.identifier.system = $ura
* identifier[AssignedId].assigner.identifier.value = "312132312"
* identifier[+].system = "https://www.ozoverbindzorg.nl/namingsystem/ozo-connect/professional"
* identifier[=].value = "1142"
* identifier[+].system = "https://www.ozoverbindzorg.nl/namingsystem/email"
* identifier[=].value = "j.vandenberg@fysiotherapie.nl"
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
