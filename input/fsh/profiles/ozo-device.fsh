Profile: OZODevice
Parent: Device
Id: ozo-device
Title: "OZO Device"
Description: "Device profile for the OZO platform. Represents system components such as the AAA proxy that appear as source observers in AuditEvents."
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZODevice"
* ^name = "OZODevice"
* ^description = "Device profile for the OZO platform. Represents system components such as the AAA proxy that appear as source observers in AuditEvents."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// Identifiers - open slicing, any system accepted
* identifier 0..* MS
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Open slicing. Common system: https://www.ozoverbindzorg.nl/namingsystem/device"

// Status
* status 0..1 MS
* status ^short = "active | inactive | entered-in-error | unknown"

// Device name
* deviceName 0..* MS

// Type (e.g., application server)
* type 0..1 MS
