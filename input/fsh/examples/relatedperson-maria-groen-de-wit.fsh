Instance: Maria-Groen-de-Wit
InstanceOf: OZORelatedPerson
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson"
* meta.versionId = "1"
* meta.lastUpdated = "2025-06-19T10:18:00.000+00:00"
* identifier[0].system = "https://www.ozoverbindzorg.nl/namingsystem/person"
* identifier[0].value = "RP-1501"
* patient = Reference(Jan-de-Hoop) "Jan de Hoop"
* patient.type = "Patient"
* relationship.coding.system = "http://terminology.hl7.org/CodeSystem/v3-RoleCode"
* relationship.coding.code = #SPS
* relationship.coding.display = "spouse"
* relationship.text = "Echtgenote"
* name.text = "Maria Groen-de Wit"
* name.given = "Maria"
* name.family = "Groen-de Wit"
* name.family.extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
* name.family.extension.valueString = "de Wit"
* telecom[0].system = #phone
* telecom[0].value = "+31612345679"
* telecom[0].use = #mobile
* telecom[1].system = #email
* telecom[1].value = "maria.groen@example.com"
* address.line = "Hoofdstraat 123"
* address.city = "Amsterdam"
* address.postalCode = "1234 AB"
* address.country = "NL"
* active = true