Profile: OZOOrganization
Parent: Organization
Id: ozo-organization
Title: "OZO Organization"
Description: "Organization profile for the OZO platform. Represents healthcare organizations (hospitals, pharmacies, general practices) that employ practitioners in the care network."
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOOrganization"
* ^name = "OZOOrganization"
* ^description = "Organization profile for the OZO platform. Represents healthcare organizations (hospitals, pharmacies, general practices) that employ practitioners in the care network."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// Identifiers - open slicing, any system accepted
* identifier 0..* MS
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Open slicing. Any identifier system is accepted. Common systems include URA, AGB, and OZO platform identifiers."

// Name is required
* name 1..1 MS
* name ^short = "Organization name"
* name ^definition = "Name of the healthcare organization"
