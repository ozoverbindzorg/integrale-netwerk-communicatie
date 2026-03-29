Instance: ozo-aaa-proxy-001
InstanceOf: Device
Usage: #example
Title: "OZO AAA Proxy Device"
Description: "Device representing the OZO AAA Proxy instance. Referenced by AuditEvent.source.observer via logical identifier."
* meta.versionId = "1"
* meta.lastUpdated = "2025-01-08T09:00:00.000+01:00"
* identifier.system = "https://www.ozoverbindzorg.nl/namingsystem/device"
* identifier.value = "aaa-proxy-001"
* status = #active
* manufacturer = "Headease"
* deviceName[0].name = "OZO AAA Proxy Instance 001"
* deviceName[=].type = #user-friendly-name
* type = http://snomed.info/sct#706689003 "Application server"
* note[0].text = "AAA (Authentication, Authorization, Accounting) Proxy for OZO platform providing FHIR API access control and audit logging for NEN7510 compliance"
