Instance: CareTeam-H-de-Boer
InstanceOf: CareTeam
Usage: #example
* meta.versionId = "1"
* meta.lastUpdated = "2024-12-05T16:24:57.767+00:00"
* meta.source = "#bHxcc9zOwXaXp92c"
* status = #active
* subject = Reference(Patient-H-de-Boer) "H. de Boer"
* subject.type = "Patient"
* participant[0].member = Reference(RelatedPerson-Kees-Groot)
* participant[=].member.type = "RelatedPerson"
* participant[+].member = Reference(Practitioner-Manu-van-Weel) "Manu van Weel"
* participant[=].member.type = "Practitioner"
* participant[=].onBehalfOf = Reference(Organization-Ziekenhuis-Amsterdam-2) "Ziekenhuis de Amsterdam"
* participant[=].onBehalfOf.type = "Organization"
* participant[+].member = Reference(Practitioner-Mark-Benson) "Mark Benson"
* participant[=].member.type = "Practitioner"
* participant[=].onBehalfOf = Reference(Organization-Huisarts-Amsterdam) "Huisarts van Amsterdam"
* participant[=].onBehalfOf.type = "Organization"
* participant[+].member = Reference(Practitioner-A-P-Otheeker) "A.P. Otheeker"
* participant[=].member.type = "Practitioner"
* participant[=].onBehalfOf = Reference(Organization-Apotheek-de-Pil) "Apotheek de Pil"
* participant[=].onBehalfOf.type = "Organization"