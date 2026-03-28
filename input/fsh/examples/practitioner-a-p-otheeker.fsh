Instance: A-P-Otheeker
InstanceOf: OZOPractitioner
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* meta.versionId = "1"
* meta.lastUpdated = "2024-12-05T16:24:57.115+00:00"
* meta.source = "#DcsI5fG7KexfXCQg"
* identifier[0].system = "https://www.ozoverbindzorg.nl/namingsystem/professional"
* identifier[0].value = "practitioner-a-p-otheeker"
* identifier[0].assigner.identifier.type.coding.system = $provenance-participant-type
* identifier[0].assigner.identifier.type.coding.code = #author
* identifier[0].assigner.identifier.system = $ura
* identifier[0].assigner.identifier.value = "12312312"
* identifier[+].system = "https://www.ozoverbindzorg.nl/namingsystem/ozo-connect/professional"
* identifier[=].value = "PRAC-005"
* identifier[+].system = "https://www.ozoverbindzorg.nl/namingsystem/email"
* identifier[=].value = "a.otheeker@apotheek-de-pil.nl"
* active = true
* name.text = "A.P. Otheeker"
* name.family = "Otheeker"
* name.given[0] = "Adrie"
* name.given[+] = "Pieter"
