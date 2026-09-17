// Invariant definition (must be outside the profile)
Invariant: ozo-communicationrequest-unique-recipients
Description: "Each recipient can appear at most once in a CommunicationRequest. Compares the literal recipient.reference strings; logical references via identifier (no reference field) are not de-duplicated."
Expression: "recipient.reference.distinct().count() = recipient.reference.count()"
Severity: #error

// The initiating CareTeam must be a recipient as well: the AAA proxy scopes thread access on
// recipient, and HAPI cannot OR across search parameters (recipient OR sender-careteam).
Invariant: ozo-cr-sender-careteam-in-recipient
Description: "When extension[senderCareTeam] is present, the referenced CareTeam must also be listed in recipient. The AAA proxy scopes thread access on recipient; without this entry the initiating team cannot see its own thread."
Severity: #error
Expression: "extension('http://ozoverbindzorg.nl/fhir/StructureDefinition/ozo-sender-careteam').empty() or (extension('http://ozoverbindzorg.nl/fhir/StructureDefinition/ozo-sender-careteam').value.reference in recipient.reference)"

Profile: OZOCommunicationRequest
Parent: CommunicationRequest
Id: ozo-communicationrequest
Title: "OZO CommunicationRequest"
Description: "CommunicationRequest profile for the OZO platform. Represents a message thread or conversation within the care network. Individual messages are Communication resources that reference this thread via partOf."
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
* requester only Reference(OZOPractitioner or OZORelatedPerson or OZOPatient)
* requester ^short = "Who created the thread"
* requester ^definition = "The individual (practitioner or related person) who initiated the thread. Must be an individual for auditability purposes."
* requester.reference 1..1
* requester.type 1..1

// Sender - reply-to address for the thread (individual sender)
* sender 0..1 MS
* sender only Reference(OZOPractitioner or OZORelatedPerson or OZOPatient)
* sender ^short = "Individual reply-to address"
* sender ^definition = "The individual entity to reply to. For team-level messaging, use the senderCareTeam extension instead."
* sender.reference 1..1
* sender.type 1..1

// Extension for CareTeam as sender (for team-level messaging)
* extension contains OZOSenderCareTeam named senderCareTeam 0..1 MS
* extension[senderCareTeam] ^short = "Initiating CareTeam (reply-to address for team-level messaging)"
* extension[senderCareTeam] ^definition = "The CareTeam on whose behalf the thread was started. The same CareTeam must also be listed in recipient (invariant ozo-cr-sender-careteam-in-recipient) so that the thread is in the initiating team's access scope."

// Recipients - all participants of the thread
* recipient 1..* MS
* recipient only Reference(OZOPractitioner or OZORelatedPerson or OZOCareTeam or OZOOrganizationalCareTeam)
* recipient ^short = "Thread participants"
* recipient ^definition = "All participants of the thread (practitioners, related persons, or care teams). For team-to-team threads this lists every participating team, including the initiating team referenced in extension[senderCareTeam]. The AAA proxy scopes access to threads, messages and Tasks on this element."
* recipient.reference 1..1
* recipient.type 1..1

// Constraints
* obeys ozo-communicationrequest-unique-recipients
* obeys ozo-cr-sender-careteam-in-recipient

// Extension definition for CareTeam as sender
Extension: OZOSenderCareTeam
Id: ozo-sender-careteam
Title: "OZO Sender CareTeam"
Description: "Extension to specify a CareTeam as the sender/reply-to address for team-level messaging. This extension is needed because CommunicationRequest.sender does not allow CareTeam references in FHIR R4."
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/ozo-sender-careteam"
* ^status = #active
* value[x] only Reference(OZOOrganizationalCareTeam)
* valueReference 1..1
* valueReference ^short = "CareTeam as sender"
* valueReference ^definition = "Reference to the CareTeam acting as the sender/reply-to address for team-level messaging"

// Search parameter on the extension: find threads initiated by a given CareTeam
Instance: ozo-communicationrequest-sender-careteam
InstanceOf: SearchParameter
Usage: #definition
Title: "OZO CommunicationRequest sender-careteam"
Description: "Search parameter on CommunicationRequest.extension[senderCareTeam]: find the threads initiated by a given CareTeam."
* url = "http://ozoverbindzorg.nl/fhir/SearchParameter/ozo-communicationrequest-sender-careteam"
* name = "OZOCommunicationRequestSenderCareTeam"
* status = #active
* experimental = false
* date = "2026-09-17"
* publisher = "Headease"
* description = "Find CommunicationRequest resources (threads) initiated by a given CareTeam. Matches the CareTeam referenced in the senderCareTeam extension (http://ozoverbindzorg.nl/fhir/StructureDefinition/ozo-sender-careteam). Example: CommunicationRequest?sender-careteam=CareTeam/Pharmacy-A"
* code = #sender-careteam
* base = #CommunicationRequest
* type = #reference
* expression = "CommunicationRequest.extension('http://ozoverbindzorg.nl/fhir/StructureDefinition/ozo-sender-careteam').value.ofType(Reference)"
* target = #CareTeam
