Profile: OZOPractitioner
Parent: Practitioner
Id: ozo-practitioner
Title: "OZO Practitioner"
Description: "Practitioner profile for the OZO platform. Represents healthcare professionals who are part of the patient's care team."
* ^version = "1.0.0"
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* ^name = "OZO Practitioner"
* ^description = "Practitioner profile for the OZO platform. Represents healthcare professionals who are part of the patient's care team."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// Identifiers - OZO Professional and email
* identifier 1..* MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Slice based on identifier system"

* identifier contains
    ozoProfessionalId 1..1 MS and
    email 0..1 MS

* identifier[ozoProfessionalId].system 1..1
* identifier[ozoProfessionalId].system = "OZO-CONNECT/Professional" (exactly)
* identifier[ozoProfessionalId].value 1..1
* identifier[ozoProfessionalId] ^short = "OZO Professional identifier"
* identifier[ozoProfessionalId] ^definition = "Unique identifier for the practitioner within the OZO Connect system"

* identifier[email].system 1..1
* identifier[email].system = "email" (exactly)
* identifier[email].value 1..1
* identifier[email] ^short = "Email identifier"
* identifier[email] ^definition = "Email address of the practitioner"

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
