Instance: Practitioner-Mark-Benson
InstanceOf: OZOPractitioner
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* meta.versionId = "1"
* meta.lastUpdated = "2024-12-05T16:24:56.583+00:00"
* meta.source = "#3BXUq4cav1bNYSUb"
* identifier[AssignedId].system = "https://ozo.headease.nl/practitioners"
* identifier[AssignedId].value = "practitioner-mark-benson"
* identifier[AssignedId].assigner.identifier.type.coding.system = $provenance-participant-type
* identifier[AssignedId].assigner.identifier.type.coding.code = #author
* identifier[AssignedId].assigner.identifier.system = $ura
* identifier[AssignedId].assigner.identifier.value = "312132312"
* identifier[+].system = "https://www.ozoverbindzorg.nl/namingsystem/ozo-connect/professional"
* identifier[=].value = "743227"
* identifier[+].system = "https://www.ozoverbindzorg.nl/namingsystem/email"
* identifier[=].value = "info@example.com"
* active = true
* name.text = "Mark Benson"
* name.family = "Mark"
* name.given[0] = "Mark"
* name.given[+] = "Andrew"
