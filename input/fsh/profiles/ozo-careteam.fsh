Profile: OZOCareTeam
Parent: CareTeam
Id: ozo-careteam
Title: "OZO CareTeam"
Description: "CareTeam profile for patient care networks in OZO. Represents a care network of healthcare professionals and informal caregivers coordinating care for a specific patient. For organizational teams (departments, shared inboxes), use OZOOrganizationalCareTeam instead."
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCareTeam"
* ^name = "OZOCareTeam"
* ^description = "CareTeam profile for patient care networks in OZO. Represents a care network of healthcare professionals and informal caregivers coordinating care for a specific patient. For organizational teams (departments, shared inboxes), use OZOOrganizationalCareTeam instead."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// Status is required
* status 1..1 MS
* status ^short = "CareTeam status"
* status ^definition = "Indicates the current state of the care team (proposed | active | suspended | inactive | entered-in-error)"

// Subject (patient) is required
* subject 1..1 MS
* subject only Reference(OZOPatient)
* subject ^short = "Who care team is for"
* subject ^definition = "Reference to the patient that this care team is providing care for"
* subject.reference 1..1
* subject.type 1..1
* subject.display 0..1 MS

// Participants - at least one required
* participant 1..* MS
* participant ^short = "Members of the care team"
* participant ^definition = "Participants in the care team, including practitioners and related persons"

* participant.member 1..1 MS
* participant.member only Reference(OZOPractitioner or OZORelatedPerson or OZOPatient or OZOOrganizationalCareTeam)
* participant.member ^short = "Who is on the team"
* participant.member ^definition = "Reference to the practitioner, related person, or patient who is a member of this care team. A patient may participate in their own care network (e.g., self-reliant clients)."
* participant.member.reference 1..1
* participant.member.type 1..1
* participant.member.display 0..1 MS

* participant.onBehalfOf 0..1 MS
* participant.onBehalfOf only Reference(OZOOrganization)
* participant.onBehalfOf ^short = "Organization of the practitioner"
* participant.onBehalfOf ^definition = "The organization on whose behalf the practitioner is participating in the care team"
* participant.onBehalfOf.reference 1..1
* participant.onBehalfOf.type 1..1
* participant.onBehalfOf.display 0..1 MS
