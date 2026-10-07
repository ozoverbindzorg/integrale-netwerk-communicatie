// Invariant definition (must be outside the profile)
Invariant: ozo-task-unique-basedon
Description: "Each basedOn reference (thread linkage) can appear at most once in a Task. Compares the literal basedOn.reference strings; logical references via identifier (no reference field) are not de-duplicated."
Expression: "basedOn.reference.distinct().count() = basedOn.reference.count()"
Severity: #error

Profile: OZOTask
Parent: Task
Id: ozo-task
Title: "OZO Task"
Description: "Task profile for the OZO platform. Represents work assignments, referrals, or action items within the care network. Tasks can be linked to message threads via basedOn."
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask"
* ^name = "OZOTask"
* ^description = "Task profile for the OZO platform. Represents work assignments, referrals, or action items within the care network. Tasks can be linked to message threads via basedOn."
* ^status = #active
* ^publisher = "Headease"
* ^contact[0].name = "Headease"
* ^contact[=].telecom[0].system = #url
* ^contact[=].telecom[=].value = "https://headease.nl"

// BasedOn - link to the thread that spawned this task
* basedOn 0..* MS
* basedOn only Reference(OZOCommunicationRequest)
* basedOn ^short = "Related thread"
* basedOn ^definition = "Reference to the CommunicationRequest (thread) that this task is based on"

// Status is required
* status 1..1 MS
* status ^short = "Task status"
* status ^definition = "The current status of the task (draft | requested | received | accepted | rejected | ready | cancelled | in-progress | on-hold | failed | completed | entered-in-error)"

// Intent is required
* intent 1..1 MS
* intent ^short = "Task intent"
* intent ^definition = "Indicates the actionability associated with the task (unknown | proposal | plan | order | original-order | reflex-order | filler-order | instance-order | option)"

// For - the patient this task is about
* for 1..1 MS
* for only Reference(OZOPatient)
* for ^short = "Beneficiary of the task"
* for ^definition = "Reference to the patient that this task is for"
* for.reference 1..1
* for.type 1..1
* for.display 0..1 MS

// Focus - points to the latest Communication in the thread
* focus 0..1 MS
* focus only Reference(OZOCommunication)
* focus ^short = "Latest Communication in the thread"
* focus ^definition = "Reference to the latest Communication in the thread. Updated by the OZO FHIR Api when a new message arrives in the thread. This field provides a pointer to the most recent unread message for clients using the Task as a read/unread indicator, and ensures Task subscriptions fire even when the status value doesn't change (because the resource content genuinely changes when focus is updated)."

// Owner - whose inbox state this task is
* owner 1..1 MS
* owner only Reference(OZOPractitioner or OZORelatedPerson or OZOPatient or OZOOrganizationalCareTeam)
* owner ^short = "Task owner: a person or an organizational team"
* owner ^definition = "The party whose read state this Task holds. An individual (practitioner, related person or self-reliant patient) for parties addressed individually or through a patient care team; an organizational CareTeam (OZOOrganizationalCareTeam) for a team that takes part in a team thread. The OZO FHIR Api creates one Task per organizational team (the team's shared inbox state) and one Task per member of a patient care team. During the 0.9.0 transition an OZO FHIR Api may still run the 0.8.x mode, one Task per member of an organizational team as well; clients must accept both a person and a CareTeam as owner."
* owner.reference 1..1

// Constraints
* obeys ozo-task-unique-basedon
