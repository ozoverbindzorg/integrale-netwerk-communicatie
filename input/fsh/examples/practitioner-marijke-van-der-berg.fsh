Instance: Marijke-van-der-Berg
InstanceOf: OZOPractitioner
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* meta.versionId = "1"
* meta.lastUpdated = "2025-05-28T11:24:32.833+00:00"
* identifier[0].system = "https://www.ozoverbindzorg.nl/namingsystem/professional"
* identifier[0].value = "practitioner-marijke-van-der-berg"
* identifier[0].assigner.identifier.type.coding.system = $provenance-participant-type
* identifier[0].assigner.identifier.type.coding.code = #author
* identifier[0].assigner.identifier.system = $ura
* identifier[0].assigner.identifier.value = "23123123123"
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
