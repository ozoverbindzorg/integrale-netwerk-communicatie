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

// Identifiers - open slicing, any system accepted
* identifier 0..* MS
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Open slicing. Any identifier system is accepted. Common systems include BSN and OZO platform identifiers."

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
