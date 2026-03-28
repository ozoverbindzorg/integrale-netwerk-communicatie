Profile: OZOPractitioner
Parent: NlGfPractitioner
Id: ozo-practitioner
Title: "OZO Practitioner"
Description: "Practitioner profile for the OZO platform. Extends the NL Generic Functions Practitioner profile for care services directory compliance. Represents healthcare professionals who are part of the patient's care team."
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* ^name = "OZOPractitioner"
* ^description = "Practitioner profile for the OZO platform. Extends the NL Generic Functions Practitioner profile for care services directory compliance. Represents healthcare professionals who are part of the patient's care team."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// AssignedId inherited from NlGfPractitioner — set system for HAPI discriminator matching (HAPI-0574)
* identifier[AssignedId] ^patternIdentifier.system = "https://www.ozoverbindzorg.nl/namingsystem/professional"

// Additional recognized identifier slices (open slicing inherited from NL-GF)
* identifier contains
    big 0..* MS and
    uzi 0..* MS and
    agb 0..* MS

* identifier[big].system 1..1
* identifier[big].system = "http://fhir.nl/fhir/NamingSystem/big" (exactly)
* identifier[big].value 1..1
* identifier[big] ^short = "BIG registration number"
* identifier[big] ^definition = "Dutch healthcare professional registration number (BIG-register)"

* identifier[uzi].system 1..1
* identifier[uzi].system = "http://fhir.nl/fhir/NamingSystem/uzi-nr-pers" (exactly)
* identifier[uzi].value 1..1
* identifier[uzi] ^short = "UZI number"
* identifier[uzi] ^definition = "Dutch healthcare professional UZI card number"

* identifier[agb].system 1..1
* identifier[agb].system = "http://fhir.nl/fhir/NamingSystem/agb-z" (exactly)
* identifier[agb].value 1..1
* identifier[agb] ^short = "AGB code"
* identifier[agb] ^definition = "Dutch healthcare provider AGB code (practitioner)"

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
