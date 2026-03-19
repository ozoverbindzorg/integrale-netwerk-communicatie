Instance: Netwerk-H-de-Boer
InstanceOf: OZOCareTeam
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCareTeam"
* meta.versionId = "1"
* meta.lastUpdated = "2024-12-05T16:24:57.767+00:00"
* meta.source = "#bHxcc9zOwXaXp92c"
* status = #active
* subject = Reference(H-de-Boer) "H. de Boer"
* subject.type = "Patient"
* participant[0].member = Reference(Kees-Groot)
* participant[=].member.type = "RelatedPerson"
* participant[+].member = Reference(Manu-van-Weel) "Manu van Weel"
* participant[=].member.type = "Practitioner"
* participant[=].onBehalfOf = Reference(Ziekenhuis-Amsterdam-2) "Ziekenhuis de Amsterdam"
* participant[=].onBehalfOf.type = "Organization"
* participant[+].member = Reference(Mark-Benson) "Mark Benson"
* participant[=].member.type = "Practitioner"
* participant[=].onBehalfOf = Reference(Huisarts-Amsterdam) "Huisarts van Amsterdam"
* participant[=].onBehalfOf.type = "Organization"
* participant[+].member = Reference(A-P-Otheeker) "A.P. Otheeker"
* participant[=].member.type = "Practitioner"
* participant[=].onBehalfOf = Reference(Apotheek-de-Pil) "Apotheek de Pil"
* participant[=].onBehalfOf.type = "Organization"