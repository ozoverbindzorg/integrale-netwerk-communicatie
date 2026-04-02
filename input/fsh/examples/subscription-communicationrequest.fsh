Instance: Subscription-CommunicationRequest
InstanceOf: Subscription
Usage: #example
Title: "Subscription: Thread Lifecycle"
Description: "Subscription for detecting new threads and thread status changes. Fires when a CommunicationRequest is created or its status changes (e.g. DRAFT to ACTIVE). Uses the notify-then-pull pattern: the notification payload is empty, and the subscriber must fetch the CommunicationRequest resource separately."
* status = #off
* reason = "Notify when CommunicationRequest is created or status changes"
* criteria = "CommunicationRequest?id"
* channel.type = #rest-hook
* channel.endpoint = "https://ozo-platform.example.com/fhir/subscription/thread"
