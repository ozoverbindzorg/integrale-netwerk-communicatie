Instance: Department-Thuiszorg
InstanceOf: OZOOrganizationalCareTeam
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOOrganizationalCareTeam"
* meta.versionId = "1"
* meta.lastUpdated = "2025-06-19T11:00:00.000+00:00"
* identifier[0].system = "https://www.ozoverbindzorg.nl/namingsystem/team"
* identifier[0].value = "40"
* identifier[1].system = "https://www.ozoverbindzorg.nl/namingsystem/email"
* identifier[1].value = "thuiszorg.oost@zorgorganisatie.nl"
* name = "Afdeling Thuiszorg Oost"
* status = #active
* category.coding.system = "http://snomed.info/sct"
* category.coding.code = #394730007
* category.coding.display = "Healthcare related organization"
* category.text = "Thuiszorg Afdeling"
* participant[0].member = Reference(Annemiek-Jansen) "Annemiek Jansen"
* participant[0].member.type = "Practitioner"
* participant[0].role.coding.system = "http://snomed.info/sct"
* participant[0].role.coding.code = #224535009
* participant[0].role.coding.display = "Registered nurse"
* participant[0].role.text = "Verpleegkundige"
* participant[1].member = Reference(Sophie-de-Boer) "Sophie de Boer"
* participant[1].member.type = "Practitioner"
* participant[1].role.coding.system = "http://snomed.info/sct"
* participant[1].role.coding.code = #224535009
* participant[1].role.coding.display = "Registered nurse"
* participant[1].role.text = "Verpleegkundige"
* participant[2].member = Reference(Lars-Hendriks) "Lars Hendriks"
* participant[2].member.type = "Practitioner"
* participant[2].role.coding.system = "http://snomed.info/sct"
* participant[2].role.coding.code = #224540007
* participant[2].role.coding.display = "Community nurse"
* participant[2].role.text = "Wijkverpleegkundige"
* managingOrganization.type = #Organization
* managingOrganization.reference = "Organization/1354"
* managingOrganization.display = "Zorgorganisatie Oost Nederland"
* note.text = "Dit is een afdeling thuiszorg team zonder specifieke patiënt toewijzing"