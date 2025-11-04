Profile: OZOTask
Parent: Task
Id: ozo-task
Title: "OZO Task"
Description: "Task profile for the OZO platform. Represents work assignments, referrals, or action items within the care network. Tasks can be linked to message threads via basedOn."
* ^version = "1.0.0"
* ^url = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask"
* ^name = "OZO Task"
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

// Owner - who is responsible for the task
* owner 1..1 MS
* owner only Reference(OZOPractitioner or OZORelatedPerson)
* owner ^short = "Task owner"
* owner ^definition = "The entity (practitioner or related person) who owns and is responsible for completing this task"
* owner.reference 1..1
