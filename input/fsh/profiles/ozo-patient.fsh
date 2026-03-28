Profile: OZOPatient
Parent: Patient
Id: ozo-patient
Title: "OZO Patient"
Description: "Patient profile for the OZO platform. Represents the client/patient who is the subject of care coordination between healthcare professionals and informal caregivers."
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPatient"
* ^name = "OZOPatient"
* ^description = "Patient profile for the OZO platform. Represents the client/patient who is the subject of care coordination between healthcare professionals and informal caregivers."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// At least one identifier required, open slicing for any system
* identifier 1..* MS
* identifier ^slicing.discriminator.type = #pattern
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Open slicing on identifier system. Recognized slices include BSN and email. Any OZO system (https://www.ozoverbindzorg.nl/namingsystem/...) is supported through open slicing."

// Recognized national identifier slices
* identifier contains
    bsn 0..* MS and
    email 0..* MS

* identifier[bsn].system 1..1
* identifier[bsn].system = "http://fhir.nl/fhir/NamingSystem/bsn" (exactly)
* identifier[bsn].value 1..1
* identifier[bsn] ^short = "BSN (Burgerservicenummer)"
* identifier[bsn] ^definition = "Dutch citizen service number"

* identifier[email].system 1..1
* identifier[email].system = "https://www.ozoverbindzorg.nl/namingsystem/email" (exactly)
* identifier[email].value 1..1
* identifier[email] ^short = "Email identifier"
* identifier[email] ^definition = "Email address of the patient"

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
