Profile: OZOPatient
Parent: Patient
Id: ozo-patient
Title: "OZO Patient"
Description: "Patient profile for the OZO platform. Represents the client/patient who is the subject of care coordination between healthcare professionals and informal caregivers."
* ^version = "0.2.1"
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPatient"
* ^name = "OZOPatient"
* ^description = "Patient profile for the OZO platform. Represents the client/patient who is the subject of care coordination between healthcare professionals and informal caregivers."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// Mandatory identifier for OZO system
* identifier 1..* MS
* identifier ^slicing.discriminator.type = #pattern
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Slice based on identifier system pattern. Additional OZO-* systems (e.g., OZO-MOBILE, OZO-WEB) are supported through open slicing."

* identifier contains
    ozoPersonId 0..1 MS and
    ozoConnectPersonId 0..1 MS

* identifier[ozoPersonId].system 1..1
* identifier[ozoPersonId].system = "OZO/Person" (exactly)
* identifier[ozoPersonId].value 1..1
* identifier[ozoPersonId] ^short = "OZO Person identifier"
* identifier[ozoPersonId] ^definition = "Unique identifier for the patient within the OZO system"

* identifier[ozoConnectPersonId].system 1..1
* identifier[ozoConnectPersonId].system = "OZO-CONNECT/Person" (exactly)
* identifier[ozoConnectPersonId].value 1..1
* identifier[ozoConnectPersonId] ^short = "OZO-CONNECT Person identifier"
* identifier[ozoConnectPersonId] ^definition = "Unique identifier for the patient within the OZO-CONNECT system"

// Require at least one OZO Person identifier
* obeys ozo-patient-has-person-id

// Name is required (following NL-core naming conventions)
* name 1..* MS
* name ^short = "Patient name"
* name ^definition = "The name of the patient, following Dutch naming conventions (ZIB NameInformation)"
* name.text 0..1 MS
* name.family 1..1 MS
* name.given 0..* MS

// Telecom for contact information
* telecom 0..* MS
* telecom ^short = "Contact details for the patient"
* telecom.system 1..1 MS
* telecom.value 1..1 MS

// Gender is required
* gender 1..1 MS
* gender ^short = "Patient gender"
* gender ^definition = "Administrative gender of the patient"

// BirthDate is required
* birthDate 1..1 MS
* birthDate ^short = "Patient birth date"
* birthDate ^definition = "The date of birth of the patient"

// Active status (default should be true for active patients)
* active 0..1 MS
* active ^short = "Whether this patient record is in active use"
* active ^definition = "Whether this patient's record is in active use. Default is true."

// Invariant definition (must be outside the profile)
Invariant: ozo-patient-has-person-id
Description: "Patient must have at least one OZO Person identifier (matching pattern OZO*/Person)"
Expression: "identifier.where(system.matches('^OZO[^/]*/Person$')).exists()"
Severity: #error
