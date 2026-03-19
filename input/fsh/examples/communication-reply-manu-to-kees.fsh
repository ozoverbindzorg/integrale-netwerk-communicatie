Instance: Reply-Manu-to-Kees
InstanceOf: OZOCommunication
Usage: #example
Title: "Reply from Practitioner Manu to RelatedPerson Kees"
Description: "Practitioner Manu van Weel replies to Kees Groot's initial message in the Thread-Example thread."
* meta.profile = "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication"
* partOf = Reference(Thread-Example)
* partOf.type = "CommunicationRequest"
* status = #in-progress
* sender = Reference(Manu-van-Weel) "Manu van Weel"
* sender.type = "Practitioner"
* recipient = Reference(Kees-Groot) "Kees Groot"
* recipient.type = "RelatedPerson"
* payload.contentString = "Goedemorgen Kees, bedankt voor uw bericht. Ik heb het rapport bekeken en zal dit bespreken met het team."
