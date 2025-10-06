Instance: ozo-aaa-proxy-001
InstanceOf: Device
Usage: #example
Title: "OZO AAA Proxy Device"
Description: "Device representing the OZO AAA Proxy instance"
* meta.versionId = "1"
* meta.lastUpdated = "2025-01-08T09:00:00.000+01:00"
* identifier[0].system = "http://headease.nl/ozo/device-identifier"
* identifier[=].value = "aaa-proxy-001"
* status = #active
* manufacturer = "Headease"
* deviceName[0].name = "OZO AAA Proxy Instance 001"
* deviceName[=].type = #user-friendly-name
* modelNumber = "1.0.0"
* type = http://snomed.info/sct#706689003 "Application server"
* property[0].type = http://terminology.hl7.org/CodeSystem/device-component-property#software-version
* property[=].valueCode[0].text = "1.0.0"
* note[0].text = "AAA (Authentication, Authorization, Accounting) Proxy for OZO platform providing FHIR API access control and audit logging for NEN7510 compliance"