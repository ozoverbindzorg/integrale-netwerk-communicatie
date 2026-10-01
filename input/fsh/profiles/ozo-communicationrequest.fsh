// Invariant definition (must be outside the profile)
Invariant: ozo-communicationrequest-unique-recipients
Description: "Each recipient can appear at most once in a CommunicationRequest. Compares the literal recipient.reference strings; logical references via identifier (no reference field) are not de-duplicated."
Expression: "recipient.reference.distinct().count() = recipient.reference.count()"
Severity: #error

// The initiating CareTeam is referenced in extension[senderCareTeam] only. recipient lists the
// addressed parties. Access scoping uses the participant SearchParameter, a union over both
// elements, so the initiating team no longer needs a recipient entry (0.9.0; the 0.8.x
// invariant ozo-cr-sender-careteam-in-recipient required the duplicate).
Invariant: ozo-cr-sender-careteam-not-in-recipient
Description: "When extension[senderCareTeam] is present, the referenced CareTeam must not be listed in recipient. recipient contains the addressed parties only; the initiating team is identified by the extension. The participant search parameter covers both elements for access scoping."
Severity: #error
Expression: "extension('http://ozoverbindzorg.nl/fhir/StructureDefinition/ozo-sender-careteam').empty() or (extension('http://ozoverbindzorg.nl/fhir/StructureDefinition/ozo-sender-careteam').value.reference in recipient.reference).not()"

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
* extension[senderCareTeam] ^definition = "The organizational CareTeam on whose behalf the thread was started. It is a thread party like the recipients: the participant search parameter matches it, the AAA proxy grants its members access to the thread, and the OZO FHIR Api keeps one Task for it. It must not be repeated in recipient (invariant ozo-cr-sender-careteam-not-in-recipient)."

// Recipients - the addressed parties of the thread
* recipient 1..* MS
* recipient only Reference(OZOPractitioner or OZORelatedPerson or OZOCareTeam or OZOOrganizationalCareTeam)
* recipient ^short = "Addressed parties"
* recipient ^definition = "The parties the thread is addressed to: practitioners, related persons, a patient care team or organizational team(s). For team-to-team threads this is the addressed team only; the initiating team is referenced in extension[senderCareTeam] and must not appear here. The thread parties are recipient plus extension[senderCareTeam]; the participant search parameter covers both."
* recipient.reference 1..1
* recipient.type 1..1

// Constraints
* obeys ozo-communicationrequest-unique-recipients
* obeys ozo-cr-sender-careteam-not-in-recipient

// Extension definition for CareTeam as sender. Used on CommunicationRequest (initiating team of
// the thread) and on Communication (team on whose behalf a message is sent).
Extension: OZOSenderCareTeam
Id: ozo-sender-careteam
Title: "OZO Sender CareTeam"
Description: "Extension to name the organizational CareTeam on whose behalf a thread is started (CommunicationRequest) or a message is sent (Communication). FHIR R4 CommunicationRequest.sender and Communication.sender do not allow CareTeam references, and the OZO model keeps sender an individual for auditability; this extension carries the team."
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/ozo-sender-careteam"
* ^status = #active
* ^context[0].type = #element
* ^context[=].expression = "CommunicationRequest"
* ^context[+].type = #element
* ^context[=].expression = "Communication"
* value[x] only Reference(OZOOrganizationalCareTeam)
* valueReference 1..1
* valueReference ^short = "CareTeam as sender"
* valueReference ^definition = "Reference to the organizational CareTeam acting as the sender (reply-to address) of the thread or message"

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

// Search parameter over all thread parties: recipient plus the initiating team in
// extension[senderCareTeam]. A union expression indexes both paths under one parameter, so the
// AAA proxy can keep scoping with a single parameter (HAPI combines different parameters with
// AND; _filter is blocked for clients). Same construction as the base R4 Observation.combo-code.
Instance: ozo-communicationrequest-participant
InstanceOf: SearchParameter
Usage: #definition
Title: "OZO CommunicationRequest participant"
Description: "Search parameter over the thread parties of a CommunicationRequest: the addressed parties in recipient and the initiating team in extension[senderCareTeam]. Used by the AAA proxy to scope access to threads and, through part-of:CommunicationRequest.participant, to messages."
* url = "http://ozoverbindzorg.nl/fhir/SearchParameter/ozo-communicationrequest-participant"
* name = "OZOCommunicationRequestParticipant"
* status = #active
* experimental = false
* date = "2026-10-01"
* publisher = "Headease"
* description = "Find CommunicationRequest resources (threads) in which the given party takes part, either as addressed party (recipient) or as initiating team (extension http://ozoverbindzorg.nl/fhir/StructureDefinition/ozo-sender-careteam). Example: CommunicationRequest?participant=CareTeam/Pharmacy-A returns the threads Pharmacy A is addressed in and the threads it initiated. Chained: Communication?part-of:CommunicationRequest.participant=CareTeam/Pharmacy-A."
* code = #participant
* base = #CommunicationRequest
* type = #reference
* expression = "CommunicationRequest.recipient | CommunicationRequest.extension('http://ozoverbindzorg.nl/fhir/StructureDefinition/ozo-sender-careteam').value.ofType(Reference)"
* target[0] = #CareTeam
* target[+] = #Practitioner
* target[+] = #RelatedPerson
* target[+] = #Patient
