Instance: RelatedPerson-Jane-Groen
InstanceOf: OZORelatedPerson
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson"
* id = "1500"
* meta.versionId = "1"
* meta.lastUpdated = "2025-06-19T10:00:00.000+00:00"
* identifier[ozoPersonId].system = "https://www.ozoverbindzorg.nl/namingsystem/ozo/person"
* identifier[ozoPersonId].value = "RP-1500"
* patient.reference = "Patient/747"
* patient.type = "Patient"
* patient.display = "Jan de Hoop"
* relationship.coding.system = "http://terminology.hl7.org/CodeSystem/v3-RoleCode"
* relationship.coding.code = #FAMMEMB
* relationship.coding.display = "family member"
* relationship.text = "Family member"
* name.text = "Jane Groen"
* name.given = "Jane"
* name.family = "Groen"
* name.family.extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
* name.family.extension.valueString = "Groen"
* telecom[0].system = #phone
* telecom[0].value = "+31612345678"
* telecom[0].use = #mobile
* telecom[1].system = #email
* telecom[1].value = "jane.groen@example.com"
* active = true