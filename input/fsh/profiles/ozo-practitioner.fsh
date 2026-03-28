Profile: OZOPractitioner
Parent: Practitioner
Id: ozo-practitioner
Title: "OZO Practitioner"
Description: "Practitioner profile for the OZO platform. Represents healthcare professionals who are part of the patient's care team."
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* ^name = "OZOPractitioner"
* ^description = "Practitioner profile for the OZO platform. Represents healthcare professionals who are part of the patient's care team."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// Identifiers - open slicing, any system accepted
* identifier 0..* MS
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Open slicing. Any identifier system is accepted. Common systems include BIG, UZI, AGB, and OZO platform identifiers."

// Active status is required
* active 1..1 MS
* active ^short = "Whether this practitioner record is in active use"
* active ^definition = "Whether this practitioner's record is in active use"

// Name is required
* name 1..* MS
* name ^short = "Practitioner name"
* name ^definition = "The name of the practitioner"
* name.text 0..1 MS
* name.family 1..1 MS
* name.given 0..* MS
