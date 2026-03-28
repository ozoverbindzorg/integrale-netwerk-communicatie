Profile: OZORelatedPerson
Parent: RelatedPerson
Id: ozo-relatedperson
Title: "OZO RelatedPerson"
Description: "RelatedPerson profile for the OZO platform. Represents informal caregivers (family members, friends) who are part of the patient's care network."
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson"
* ^name = "OZORelatedPerson"
* ^description = "RelatedPerson profile for the OZO platform. Represents informal caregivers (family members, friends) who are part of the patient's care network."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// Identifiers - open slicing, any system accepted
* identifier 0..* MS
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Open slicing. Any identifier system is accepted. Common systems include OZO platform identifiers."

// Active status is required
* active 1..1 MS
* active ^short = "Whether this related person record is in active use"
* active ^definition = "Whether this related person's record is in active use"

// Reference to the patient
* patient 1..1 MS
* patient only Reference(OZOPatient)
* patient ^short = "The patient this person is related to"
* patient ^definition = "Reference to the patient that this person is related to"
* patient.reference 1..1
* patient.type 1..1
* patient.display 0..1 MS

// Relationship to the patient
* relationship 1..* MS
* relationship ^short = "The nature of the relationship"
* relationship ^definition = "The nature of the relationship between the patient and the related person (e.g., son, daughter, spouse)"
* relationship.coding 1..* MS
* relationship.coding.system 1..1
* relationship.coding.code 1..1
* relationship.coding.display 0..1

// Name is required
* name 1..* MS
* name ^short = "Related person name"
* name ^definition = "The name of the related person"
* name.text 0..1 MS
* name.family 1..1 MS
* name.given 0..* MS
