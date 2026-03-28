Instance: Lars-Hendriks
InstanceOf: OZOPractitioner
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* meta.versionId = "1"
* meta.lastUpdated = "2025-06-19T11:02:00.000+00:00"
* identifier[AssignedId].system = "https://www.ozoverbindzorg.nl/namingsystem/professional"
* identifier[AssignedId].value = "practitioner-lars-hendriks"
* identifier[AssignedId].assigner.identifier.type.coding.system = $provenance-participant-type
* identifier[AssignedId].assigner.identifier.type.coding.code = #author
* identifier[AssignedId].assigner.identifier.system = $ura
* identifier[AssignedId].assigner.identifier.value = "23123123123"
* identifier[+].system = "https://www.ozoverbindzorg.nl/namingsystem/ozo-connect/professional"
* identifier[=].value = "1151"
* identifier[+].system = "https://www.ozoverbindzorg.nl/namingsystem/email"
* identifier[=].value = "l.hendriks@thuiszorg.nl"
* name.text = "Lars Hendriks"
* name.given = "Lars"
* name.family = "Hendriks"
* name.family.extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
* name.family.extension.valueString = "Hendriks"
* qualification.code.coding.system = "http://terminology.hl7.org/CodeSystem/v2-0360"
* qualification.code.coding.code = #RN
* qualification.code.coding.display = "Registered Nurse"
* qualification.code.text = "Wijkverpleegkundige"
* active = true
