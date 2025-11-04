Instance: RelatedPerson-Willem-Bakker
InstanceOf: OZORelatedPerson
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson"
* id = "1503"
* meta.versionId = "1"
* meta.lastUpdated = "2025-06-19T10:20:00.000+00:00"
* patient.reference = "Patient/747"
* patient.display = "Jan de Hoop"
* relationship.coding.system = "http://terminology.hl7.org/CodeSystem/v3-RoleCode"
* relationship.coding.code = #FRND
* relationship.coding.display = "unrelated friend"
* relationship.text = "Vriend/Mantelzorger"
* name.text = "Willem Bakker"
* name.given = "Willem"
* name.family = "Bakker"
* name.family.extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
* name.family.extension.valueString = "Bakker"
* telecom[0].system = #phone
* telecom[0].value = "+31612345681"
* telecom[0].use = #mobile
* telecom[1].system = #email
* telecom[1].value = "willem.bakker@example.com"
* address.line = "Kerkstraat 45"
* address.city = "Amsterdam"
* address.postalCode = "1234 CD"
* address.country = "NL"
* active = true