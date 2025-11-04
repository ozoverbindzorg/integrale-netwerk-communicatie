Profile: OZOOrganization
Parent: Organization
Id: ozo-organization
Title: "OZO Organization"
Description: "Organization profile for the OZO platform. Represents healthcare organizations (hospitals, pharmacies, general practices) that employ practitioners in the care network."
* ^version = "1.0.0"
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOOrganization"
* ^name = "OZO Organization"
* ^description = "Organization profile for the OZO platform. Represents healthcare organizations (hospitals, pharmacies, general practices) that employ practitioners in the care network."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// URA identifier (Dutch healthcare organization identifier)
* identifier 1..* MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Slice based on identifier system"

* identifier contains uraId 0..1 MS

* identifier[uraId].system 1..1
* identifier[uraId].system = "ura" (exactly)
* identifier[uraId].value 1..1
* identifier[uraId] ^short = "URA identifier"
* identifier[uraId] ^definition = "URA (Unieke Registratie Apothekers) or similar Dutch healthcare organization identifier"

// Name is required
* name 1..1 MS
* name ^short = "Organization name"
* name ^definition = "Name of the healthcare organization"
