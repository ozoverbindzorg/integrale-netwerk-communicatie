Profile: OZOCommunicationRequest
Parent: CommunicationRequest
Id: ozo-communicationrequest
Title: "OZO CommunicationRequest"
Description: "CommunicationRequest profile for the OZO platform. Represents a message thread or conversation within the care network. Individual messages are Communication resources that reference this thread via partOf."
* ^version = "1.0.0"
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunicationRequest"
* ^name = "OZOCommunicationRequest"
* ^description = "CommunicationRequest profile for the OZO platform. Represents a message thread or conversation within the care network. Individual messages are Communication resources that reference this thread via partOf."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// Status is required
* status 1..1 MS
* status ^short = "Thread status"
* status ^definition = "The status of the communication request/thread (draft | active | on-hold | revoked | completed | entered-in-error | unknown)"

// Subject - the patient this thread is about
* subject 1..1 MS
* subject only Reference(OZOPatient)
* subject ^short = "Focus of message thread"
* subject ^definition = "Reference to the patient that this message thread is about"
* subject.reference 1..1
* subject.type 1..1
* subject.display 0..1 MS

// Payload - thread content (initial message and/or attachments)
* payload 0..* MS
* payload ^short = "Thread content"
* payload ^definition = "Initial message content or attachments that start the thread"
* payload.content[x] 1..1 MS
* payload.content[x] only string or Attachment

// Payload attachment details
* payload.contentAttachment.contentType 0..1 MS
* payload.contentAttachment.url 0..1 MS
* payload.contentAttachment.title 0..1 MS
* payload.contentAttachment.creation 0..1 MS

// Requester - who created the thread (individual for auditability)
* requester 1..1 MS
* requester only Reference(OZOPractitioner or OZORelatedPerson)
* requester ^short = "Who created the thread"
* requester ^definition = "The individual (practitioner or related person) who initiated the thread. Must be an individual for auditability purposes."
* requester.reference 1..1
* requester.type 1..1

// Sender - reply-to address for the thread (can be team for team-level messaging)
* sender 0..1 MS
* sender only Reference(OZOPractitioner or OZORelatedPerson or OZOCareTeam)
* sender ^short = "Reply-to address"
* sender ^definition = "The entity to reply to. Can be a CareTeam for team-level messaging, providing the reply-to address and team-level authorization for message management."
* sender.reference 1..1
* sender.type 1..1

// Recipients - who should receive the thread
* recipient 1..* MS
* recipient only Reference(OZOPractitioner or OZORelatedPerson or OZOCareTeam)
* recipient ^short = "Thread recipients"
* recipient ^definition = "The intended recipients of the thread (practitioners, related persons, or care teams)"
* recipient.reference 1..1
* recipient.type 1..1
