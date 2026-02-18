Instance: Practitioner-Marijke-van-der-Berg
InstanceOf: OZOPractitioner
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* id = "1208"
* meta.versionId = "1"
* meta.lastUpdated = "2025-05-28T11:24:32.833+00:00"
* identifier[AssignedId].system = "https://ozo.headease.nl/practitioners"
* identifier[AssignedId].value = "practitioner-marijke-van-der-berg"
* identifier[AssignedId].assigner.identifier.type.coding.system = $provenance-participant-type
* identifier[AssignedId].assigner.identifier.type.coding.code = #author
* identifier[AssignedId].assigner.identifier.system = $ura
* identifier[AssignedId].assigner.identifier.value = "23123123123"
* identifier[+].system = "https://www.ozoverbindzorg.nl/namingsystem/ozo-connect/professional"
* identifier[=].value = "1139"
* identifier[+].system = "https://www.ozoverbindzorg.nl/namingsystem/email"
* identifier[=].value = "rudolf@ozoverbindzorg.nl"
* name.text = "Marijke van der Berg"
* name.given = "Marijke"
* name.family = "van der Berg"
* name.family.extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
* name.family.extension.valueString = "van der Berg"
* active = true
