Profile: OZOOrganizationalCareTeam
Parent: CareTeam
Id: ozo-organizational-careteam
Title: "OZO Organizational CareTeam"
Description: "CareTeam profile for organizational teams in OZO. Represents a department or organizational unit (e.g., pharmacy team, clinic team) used for team-to-team messaging via shared inbox. Not bound to a specific patient."
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOOrganizationalCareTeam"
* ^name = "OZOOrganizationalCareTeam"
* ^description = "CareTeam profile for organizational teams in OZO. Represents a department or organizational unit (e.g., pharmacy team, clinic team) used for team-to-team messaging via shared inbox. Not bound to a specific patient."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// Organizational teams have no patient subject
* subject 0..0

// Status is required
* status 1..1 MS
* status ^short = "CareTeam status"
* status ^definition = "Indicates the current state of the organizational team (proposed | active | suspended | inactive | entered-in-error)"

// Name is required for display
* name 1..1 MS
* name ^short = "Team name"
* name ^definition = "The name of the organizational team (e.g., 'Apotheek de Pil - Team')"

// Category identifies the type of team (e.g., pharmacy, general medicine)
* category 0..* MS
* category ^short = "Type of team"
* category ^definition = "Optional coded category identifying the type of organizational team (e.g., pharmacy service, general medicine). Any code system may be used — SNOMED CT, the Dutch organization type list (urn:oid:2.16.840.1.113883.2.4.15.1060), or a plain text description."

// Managing organization is required - links team to its organization
* managingOrganization 1..1 MS
* managingOrganization only Reference(OZOOrganization)
* managingOrganization ^short = "Organization this team belongs to"
* managingOrganization ^definition = "The organization that manages this team"
* managingOrganization.reference 1..1
* managingOrganization.type 1..1
* managingOrganization.display 0..1 MS

// Participants - at least one required, only practitioners
* participant 1..* MS
* participant ^short = "Members of the organizational team"
* participant ^definition = "Practitioners who are members of this organizational team"

* participant.member 1..1 MS
* participant.member only Reference(OZOPractitioner)
* participant.member ^short = "Who is on the team"
* participant.member ^definition = "Reference to the practitioner who is a member of this organizational team"
* participant.member.reference 1..1
* participant.member.type 1..1
* participant.member.display 0..1 MS

* participant.onBehalfOf 0..1 MS
* participant.onBehalfOf only Reference(OZOOrganization)
* participant.onBehalfOf ^short = "Organization of the practitioner"
* participant.onBehalfOf ^definition = "The organization on whose behalf the practitioner is participating in the team"
* participant.onBehalfOf.reference 1..1
* participant.onBehalfOf.type 1..1
* participant.onBehalfOf.display 0..1 MS
