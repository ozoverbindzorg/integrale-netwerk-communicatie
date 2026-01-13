Profile: OZORelatedPerson
Parent: RelatedPerson
Id: ozo-relatedperson
Title: "OZO RelatedPerson"
Description: "RelatedPerson profile for the OZO platform. Represents informal caregivers (family members, friends) who are part of the patient's care network."
* ^version = "0.2.1"
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson"
* ^name = "OZORelatedPerson"
* ^description = "RelatedPerson profile for the OZO platform. Represents informal caregivers (family members, friends) who are part of the patient's care network."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// Identifiers - OZO Person and NetworkRelation
* identifier 1..* MS
* identifier ^slicing.discriminator.type = #pattern
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Slice based on identifier system pattern. Additional OZO-* systems (e.g., OZO-MOBILE, OZO-WEB) are supported through open slicing."

* identifier contains
    ozoPersonId 0..1 MS and
    ozoConnectPersonId 0..1 MS and
    ozoNetworkRelationId 0..1 MS and
    ozoConnectNetworkRelationId 0..1 MS and
    email 0..1 MS

* identifier[ozoPersonId].system 1..1
* identifier[ozoPersonId].system = "https://www.ozoverbindzorg.nl/namingsystem/ozo/person" (exactly)
* identifier[ozoPersonId].value 1..1
* identifier[ozoPersonId] ^short = "OZO Person identifier"
* identifier[ozoPersonId] ^definition = "Unique identifier for the related person within the OZO system"

* identifier[ozoConnectPersonId].system 1..1
* identifier[ozoConnectPersonId].system = "https://www.ozoverbindzorg.nl/namingsystem/ozo-connect/person" (exactly)
* identifier[ozoConnectPersonId].value 1..1
* identifier[ozoConnectPersonId] ^short = "OZO-CONNECT Person identifier"
* identifier[ozoConnectPersonId] ^definition = "Unique identifier for the related person within the OZO-CONNECT system"

* identifier[ozoNetworkRelationId].system 1..1
* identifier[ozoNetworkRelationId].system = "https://www.ozoverbindzorg.nl/namingsystem/ozo/network-relation" (exactly)
* identifier[ozoNetworkRelationId].value 1..1
* identifier[ozoNetworkRelationId] ^short = "OZO Network Relation identifier"
* identifier[ozoNetworkRelationId] ^definition = "Identifier for the network relationship between the related person and patient"

* identifier[ozoConnectNetworkRelationId].system 1..1
* identifier[ozoConnectNetworkRelationId].system = "https://www.ozoverbindzorg.nl/namingsystem/ozo-connect/network-relation" (exactly)
* identifier[ozoConnectNetworkRelationId].value 1..1
* identifier[ozoConnectNetworkRelationId] ^short = "OZO-CONNECT Network Relation identifier"
* identifier[ozoConnectNetworkRelationId] ^definition = "Identifier for the network relationship between the related person and patient in OZO-CONNECT"

* identifier[email].system 1..1
* identifier[email].system = "https://www.ozoverbindzorg.nl/namingsystem/email" (exactly)
* identifier[email].value 1..1
* identifier[email] ^short = "Email identifier"
* identifier[email] ^definition = "Email address of the related person (temporary - should migrate to telecom)"

// Require at least one OZO Person identifier
* obeys ozo-relatedperson-has-person-id

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

// Invariant definition (must be outside the profile)
Invariant: ozo-relatedperson-has-person-id
Description: "RelatedPerson must have at least one OZO Person identifier (matching pattern https://www.ozoverbindzorg.nl/namingsystem/ozo*/person)"
Expression: "identifier.where(system.startsWith('https://www.ozoverbindzorg.nl/namingsystem/ozo') and system.endsWith('/person')).exists()"
Severity: #error
