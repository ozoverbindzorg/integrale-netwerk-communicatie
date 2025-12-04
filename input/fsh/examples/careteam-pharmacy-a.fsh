Instance: CareTeam-Pharmacy-A
InstanceOf: OZOCareTeam
Usage: #example
Title: "CareTeam Pharmacy A - Apotheek de Pil"
Description: "Example of a pharmacy team used for team-level messaging. This CareTeam represents the pharmacy as a whole for shared inbox functionality."
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCareTeam"
* meta.versionId = "1"
* meta.lastUpdated = "2025-12-04T10:00:00.000+00:00"
* identifier[0].system = "OZO-CONNECT/Team"
* identifier[0].value = "pharmacy-a-team"
* identifier[1].system = "email"
* identifier[1].value = "apotheek@depil.nl"
* name = "Apotheek de Pil - Team"
* status = #active
* subject.reference = "Patient/example-unassigned"
* subject.type = "Patient"
* subject.display = "Organizational team - no specific patient"
* category.coding.system = "http://snomed.info/sct"
* category.coding.code = #310080006
* category.coding.display = "Pharmacy service"
* category.text = "Apotheek Team"
* participant[0].member.type = #Practitioner
* participant[0].member = Reference(Practitioner-A-P-Otheeker)
* participant[0].member.display = "A.P. Otheeker"
* participant[0].role.coding.system = "http://snomed.info/sct"
* participant[0].role.coding.code = #46255001
* participant[0].role.coding.display = "Pharmacist"
* participant[0].role.text = "Apotheker"
* participant[1].member.type = #Practitioner
* participant[1].member = Reference(Practitioner-Pieter-de-Vries)
* participant[1].member.display = "Pieter de Vries"
* participant[1].role.coding.system = "http://snomed.info/sct"
* participant[1].role.coding.code = #46255001
* participant[1].role.coding.display = "Pharmacist"
* participant[1].role.text = "Apotheker"
* managingOrganization.type = #Organization
* managingOrganization = Reference(Organization-Apotheek-de-Pil)
* managingOrganization.display = "Apotheek de Pil"
* note.text = "Team voor apotheek de Pil - gebruikt voor team-level messaging"
