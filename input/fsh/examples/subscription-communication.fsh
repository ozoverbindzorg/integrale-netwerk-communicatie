Instance: Subscription-Communication
InstanceOf: Subscription
Usage: #example
Title: "Subscription: New Message Detection"
Description: "Subscription for detecting new Communication messages. This is the primary mechanism for new-message notification. Uses the notify-then-pull pattern: the notification payload is empty, and the subscriber must fetch the Communication resource separately. This is required in the Netherlands where healthcare data must not be pushed in notifications."
* status = #requested
* reason = "Notify when new Communication messages are created"
* criteria = "Communication?id"
* channel.type = #rest-hook
* channel.endpoint = "https://ozo-client.example.nl/fhir/subscription/communication"
