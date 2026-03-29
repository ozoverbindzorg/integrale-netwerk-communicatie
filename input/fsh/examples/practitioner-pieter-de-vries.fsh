Instance: Pieter-de-Vries
InstanceOf: OZOPractitioner
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* meta.versionId = "1"
* meta.lastUpdated = "2025-06-19T10:15:00.000+00:00"
* identifier[0].system = "https://www.ozoverbindzorg.nl/namingsystem/professional"
* identifier[0].value = "practitioner-pieter-de-vries"
* identifier[0].assigner.identifier.type.coding.system = $provenance-participant-type
* identifier[0].assigner.identifier.type.coding.code = #author
* identifier[0].assigner.identifier.system = $ura
* identifier[0].assigner.identifier.value = "12312312"
* identifier[+].system = "https://www.ozoverbindzorg.nl/namingsystem/professional"
* identifier[=].value = "1140"
* identifier[+].system = "https://www.ozoverbindzorg.nl/namingsystem/email"
* identifier[=].value = "p.devries@medischcentrum.nl"
* name.text = "Dr. Pieter de Vries"
* name.given = "Pieter"
* name.family = "de Vries"
* name.family.extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
* name.family.extension.valueString = "de Vries"
* name.prefix = "Dr."
* qualification.code.coding[0].system = "http://terminology.hl7.org/CodeSystem/v2-0360"
* qualification.code.coding[0].code = #MD
* qualification.code.coding[0].display = "Doctor of Medicine"
* qualification.code.coding[1].system = "http://snomed.info/sct"
* qualification.code.coding[1].code = #223366009
* qualification.code.coding[1].display = "General practitioner"
* qualification.code.text = "Huisarts"
* active = true
