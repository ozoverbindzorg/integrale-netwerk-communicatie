Instance: 9
InstanceOf: CareTeam
Usage: #example
* meta.versionId = "1"
* meta.lastUpdated = "2024-11-27T18:00:44.318+00:00"
* meta.source = "#s4u2VxuQp6hDwSUd"
* status = #active
* subject = Reference(4) "H. de Boer"
* subject.type = "Patient"
* participant[0].member = Reference(5)
* participant[=].member.type = "RelatedPerson"
* participant[+].member = Reference(6) "Manu van Weel"
* participant[=].member.type = "Practitioner"
* participant[=].onBehalfOf = Reference(1) "Ziekenhuis de Amsterdam"
* participant[=].onBehalfOf.type = "Organization"
* participant[+].member = Reference(7) "Mark Benson"
* participant[=].member.type = "Practitioner"
* participant[=].onBehalfOf = Reference(2) "Huisarts van Amsterdam"
* participant[=].onBehalfOf.type = "Organization"
* participant[+].member = Reference(8) "A.P. Otheeker"
* participant[=].member.type = "Practitioner"
* participant[=].onBehalfOf = Reference(3) "Apotheek de Pil"
* participant[=].onBehalfOf.type = "Organization"