Profile: OZOPractitioner
Parent: NlGfPractitioner
Id: ozo-practitioner
Title: "OZO Practitioner"
Description: "Practitioner profile for the OZO platform. Extends the NL Generic Functions Practitioner profile for care services directory compliance. Represents healthcare professionals who are part of the patient's care team."
* ^version = "2.0.0"
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* ^name = "OZOPractitioner"
* ^description = "Practitioner profile for the OZO platform. Extends the NL Generic Functions Practitioner profile for care services directory compliance. Represents healthcare professionals who are part of the patient's care team."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// Identifiers - AssignedId inherited from NlGfPractitioner, OZO slices added via open slicing
// Note: NlGfPractitioner uses value:$this discriminator - do not redefine slicing discriminator here

// Require at least one OZO Professional identifier
* obeys ozo-practitioner-has-professional-id

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

// Invariant definition (must be outside the profile)
Invariant: ozo-practitioner-has-professional-id
Description: "Practitioner must have at least one OZO Professional identifier (matching pattern https://www.ozoverbindzorg.nl/namingsystem/ozo*/professional)"
Expression: "identifier.where(system.startsWith('https://www.ozoverbindzorg.nl/namingsystem/ozo') and system.endsWith('/professional')).exists()"
Severity: #error
