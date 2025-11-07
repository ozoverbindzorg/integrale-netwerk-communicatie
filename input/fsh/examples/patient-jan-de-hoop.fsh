Instance: Patient-Jan-de-Hoop
InstanceOf: OZOPatient
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPatient"
* id = "747"
* meta.versionId = "1"
* meta.lastUpdated = "2025-04-17T07:45:03.488+00:00"
* identifier[ozoPersonId].system = "OZO-CONNECT/Person"
* identifier[ozoPersonId].value = "1021"
* identifier[email].system = "email"
* identifier[email].value = "roland.groen+ozo@gmail.com"
* name.text = "Jan de Hoop"
* name.given = "Roland"
* name.family = "Groen deel 2"
* name.family.extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
* name.family.extension.valueString = "Groen deel 2"
* gender = #male
* birthDate = "1945-03-15"
* active = true