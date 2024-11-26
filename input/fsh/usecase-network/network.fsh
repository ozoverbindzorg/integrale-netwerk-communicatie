Instance: cps-patient-patrick
InstanceOf: Patient
Usage: #example
Title: "1.03.4 Patient Patrick Egger"
Description: "copy of data in EHR of Hospital X"
* meta.profile = "http://nictiz.nl/fhir/StructureDefinition/nl-core-Patient"
* identifier.system = "http://fhir.nl/fhir/NamingSystem/bsn"
* identifier.value = "111222333"
* name
  * given[0] = "Patrick"
  * family = "Egger"
* telecom[+].system = #phone
* telecom[=].value = "+31612345678"
* telecom[+].system = #email
* telecom[=].value = "patrickegger@myweb.nl"
* gender = #male
* birthDate = "1984-04-01"
