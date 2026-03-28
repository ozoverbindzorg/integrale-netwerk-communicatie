Profile: OZOOrganization
Parent: NlGfOrganization
Id: ozo-organization
Title: "OZO Organization"
Description: "Organization profile for the OZO platform. Extends the NL Generic Functions Organization profile (nl-gf-organization) for mCSD care services directory compliance. Represents healthcare organizations (hospitals, pharmacies, general practices) that employ practitioners in the care network."
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOOrganization"
* ^name = "OZOOrganization"
* ^description = "Organization profile for the OZO platform. Extends the NL Generic Functions Organization profile (nl-gf-organization) for mCSD care services directory compliance. Represents healthcare organizations (hospitals, pharmacies, general practices) that employ practitioners in the care network."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// AssignedId inherited from NlGfOrganization — set system for HAPI discriminator matching (HAPI-0574)
* identifier[AssignedId] ^patternIdentifier.system = "https://www.ozoverbindzorg.nl/namingsystem/organization"

// URA slice inherited from NL-GF (0..*, required unless partOf is set)

// Additional recognized identifier slices
* identifier contains
    agb 0..* MS

* identifier[agb].system 1..1
* identifier[agb].system = "http://fhir.nl/fhir/NamingSystem/agb-z" (exactly)
* identifier[agb].value 1..1
* identifier[agb] ^short = "AGB code"
* identifier[agb] ^definition = "Dutch healthcare provider AGB code (organization)"

// Name is required
* name 1..1 MS
* name ^short = "Organization name"
* name ^definition = "Name of the healthcare organization"
