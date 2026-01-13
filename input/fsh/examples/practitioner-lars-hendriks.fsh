Instance: Practitioner-Lars-Hendriks
InstanceOf: OZOPractitioner
Usage: #example
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner"
* id = "1221"
* meta.versionId = "1"
* meta.lastUpdated = "2025-06-19T11:02:00.000+00:00"
* identifier[ozoConnectProfessionalId].system = "https://www.ozoverbindzorg.nl/namingsystem/ozo-connect/professional"
* identifier[ozoConnectProfessionalId].value = "1151"
* identifier[email].system = "https://www.ozoverbindzorg.nl/namingsystem/email"
* identifier[email].value = "l.hendriks@thuiszorg.nl"
* name.text = "Lars Hendriks"
* name.given = "Lars"
* name.family = "Hendriks"
* name.family.extension.url = "http://hl7.org/fhir/StructureDefinition/humanname-own-name"
* name.family.extension.valueString = "Hendriks"
* qualification.code.coding.system = "http://terminology.hl7.org/CodeSystem/v2-0360"
* qualification.code.coding.code = #RN
* qualification.code.coding.display = "Registered Nurse"
* qualification.code.text = "Wijkverpleegkundige"
* active = true