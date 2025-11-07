Instance: RelatedPerson-Thomas-Groen
InstanceOf: OZORelatedPerson
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson"
* id = "1502"
* meta.versionId = "1"
* meta.lastUpdated = "2025-06-19T10:19:00.000+00:00"
* identifier[ozoPersonId].system = "OZO/Person"
* identifier[ozoPersonId].value = "RP-1502"
* patient.reference = "Patient/747"
* patient.type = "Patient"
* patient.display = "Jan de Hoop"
* relationship.coding.system = "http://terminology.hl7.org/CodeSystem/v3-RoleCode"
* relationship.coding.code = #CHILD
* relationship.coding.display = "child"
* relationship.text = "Zoon"
* name.text = "Thomas Groen"
* name.given = "Thomas"
* name.family = "Groen"
* name.family.extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
* name.family.extension.valueString = "Groen"
* telecom[0].system = #phone
* telecom[0].value = "+31612345680"
* telecom[0].use = #mobile
* telecom[1].system = #email
* telecom[1].value = "thomas.groen@example.com"
* birthDate = "1995-03-15"
* active = true