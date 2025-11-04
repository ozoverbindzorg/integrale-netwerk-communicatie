Instance: RelatedPerson-Kees-Groot
InstanceOf: OZORelatedPerson
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson"
* meta.versionId = "1"
* meta.lastUpdated = "2024-12-05T16:24:55.501+00:00"
* meta.source = "#wXk63usSROLkNN1z"
* identifier[0].system = "OZO/Person"
* identifier[=].value = "48898909439"
* identifier[+].system = "OZO/NetworkRelation"
* identifier[=].value = "0987654321"
* identifier[+].system = "email"
* identifier[=].value = "info@example.com"
* active = true
* patient = Reference(Patient-H-de-Boer) "H. de Boer"
* patient.type = "Patient"
* relationship = urn:oid:2.16.840.1.113883.5.111#SONC "Son"
* name.text = "Kees Groot"
* name.family = "Groot"
* name.given[0] = "Kees"
* name.given[+] = "Gerards"