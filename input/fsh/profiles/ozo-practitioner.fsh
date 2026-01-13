Profile: OZOPractitioner
Parent: Practitioner
Id: ozo-practitioner
Title: "OZO Practitioner"
Description: "Practitioner profile for the OZO platform. Represents healthcare professionals who are part of the patient's care team."
* ^version = "0.2.1"
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* ^name = "OZOPractitioner"
* ^description = "Practitioner profile for the OZO platform. Represents healthcare professionals who are part of the patient's care team."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// Identifiers - OZO Professional and email
* identifier 1..* MS
* identifier ^slicing.discriminator.type = #pattern
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Slice based on identifier system pattern. Additional OZO-* systems (e.g., OZO-MOBILE, OZO-WEB) are supported through open slicing."

* identifier contains
    ozoProfessionalId 0..1 MS and
    ozoConnectProfessionalId 0..1 MS and
    email 0..1 MS

* identifier[ozoProfessionalId].system 1..1
* identifier[ozoProfessionalId].system = "https://www.ozoverbindzorg.nl/namingsystem/ozo/professional" (exactly)
* identifier[ozoProfessionalId].value 1..1
* identifier[ozoProfessionalId] ^short = "OZO Professional identifier"
* identifier[ozoProfessionalId] ^definition = "Unique identifier for the practitioner within the OZO system"

* identifier[ozoConnectProfessionalId].system 1..1
* identifier[ozoConnectProfessionalId].system = "https://www.ozoverbindzorg.nl/namingsystem/ozo-connect/professional" (exactly)
* identifier[ozoConnectProfessionalId].value 1..1
* identifier[ozoConnectProfessionalId] ^short = "OZO-CONNECT Professional identifier"
* identifier[ozoConnectProfessionalId] ^definition = "Unique identifier for the practitioner within the OZO-CONNECT system"

* identifier[email].system 1..1
* identifier[email].system = "https://www.ozoverbindzorg.nl/namingsystem/email" (exactly)
* identifier[email].value 1..1
* identifier[email] ^short = "Email identifier"
* identifier[email] ^definition = "Email address of the practitioner (temporary - should migrate to telecom)"

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
