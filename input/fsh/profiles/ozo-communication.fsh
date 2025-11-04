Profile: OZOCommunication
Parent: Communication
Id: ozo-communication
Title: "OZO Communication"
Description: "Communication profile for the OZO platform. Represents messages exchanged within the care network, linking to threads via CommunicationRequest."
* ^version = "1.0.0"
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication"
* ^name = "OZOCommunication"
* ^description = "Communication profile for the OZO platform. Represents messages exchanged within the care network, linking to threads via CommunicationRequest."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// PartOf links to the thread (CommunicationRequest)
* partOf 1..* MS
* partOf only Reference(OZOCommunicationRequest)
* partOf ^short = "Part of thread"
* partOf ^definition = "Reference to the CommunicationRequest that represents the message thread this communication belongs to"
* partOf.reference 1..1
* partOf.type 1..1

// Status is required
* status 1..1 MS
* status ^short = "Communication status"
* status ^definition = "The status of the transmission (preparation | in-progress | not-done | on-hold | stopped | completed | entered-in-error | unknown)"

// Recipients - who the message is sent to
* recipient 1..* MS
* recipient only Reference(OZOPractitioner or OZORelatedPerson or OZOCareTeam)
* recipient ^short = "Message recipient"
* recipient ^definition = "The entity (practitioner, related person, or care team) who receives the message"
* recipient.reference 1..1
* recipient.type 1..1
* recipient.display 0..1 MS

// Sender - who sent the message
* sender 1..1 MS
* sender only Reference(OZOPractitioner or OZORelatedPerson)
* sender ^short = "Message sender"
* sender ^definition = "The entity (practitioner or related person) who sent the message"
* sender.reference 1..1
* sender.type 1..1
* sender.display 0..1 MS

// Payload - the message content
* payload 1..* MS
* payload ^short = "Message content"
* payload ^definition = "Text, attachment, or other data that comprises the message"
* payload.content[x] 1..1 MS
* payload.content[x] only string or Attachment
