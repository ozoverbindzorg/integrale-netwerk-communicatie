Instance: Subscription-Task-Unread
InstanceOf: Subscription
Usage: #example
Title: "Subscription: Unread Message Tracking"
Description: "Subscription for tracking unread message status via Task resources. Fires when a Task status changes to 'requested' (unread). Not suitable for new-message detection — use the Communication subscription for that. The AAA proxy automatically scopes this subscription to the current user's ownership. Uses the notify-then-pull pattern: the notification payload is empty."
* status = #off
* reason = "Notify when Task status changes to requested (unread indicator)"
* criteria = "Task?status=requested"
* channel.type = #rest-hook
* channel.endpoint = "https://ozo-client.example.nl/fhir/subscription/task-unread"
