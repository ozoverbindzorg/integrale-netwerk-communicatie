### Authorization rules of the RelatedPerson access

This table describes the access rules for a Practitioner role in a healthcare system, showing:
1. **Entities**: Various healthcare resources like Patient, CareTeam, Communication, etc.
2. **Access conditions**: When a Practitioner can access specific resources
3. **CRUD permissions**: Whether they can Create (C) and/or Read (R) the resources
4. **Validation queries**: The FHIR search queries used to validate read or create access


| Entity               | As RelatedPerson                                                           | CRUD | Read validation                                                                     | Create validation                                                                 |
|----------------------|----------------------------------------------------------------------------|------|-------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|
| RelatedPerson        | If the identity matches                                                    | R    | RelatedPerson?<br>identifier=system\|user_id                                        |                                                                                   |                   |
| Patient              | If the RelatedPerson.patient is the Patient                                | R    | Patient?<br>_has:RelatedPerson:patient:identifier=system\|user_id                   |                                                                                   |
| Practitioner         | If the RelatedPerson is in the same CareTeam as the Practitioner           | R    | Practitioner?<br>_has:CareTeam:participant:participant=RelatedPerson/1              |                                                                                   |
| CareTeam             | If the RelatedPerson is a participant of the CareTeam                      | R    | CareTeam?<br>participant:RelatedPerson=RelatedPerson/1                              |                                                                                   |
| CommunicationRequest | If the RelatedPerson or the CareTeam of the RelatedPerson is the recipient | CR   | CommunicationRequest?<br>recipient=RelatedPerson/1,CareTeam/1                       | CommunicationRequest?requester=RelatedPerson/1                                    |
| Communication        | If the part-of matches the rule above                                      | CR   | Communication?<br>part-of:CommunicationRequest.recipient=RelatedPerson/1,CareTeam/1 | Communication?sender=RelatedPerson/1 AND Communication.recipient share a CareTeam |
| AuditEvent           | If the agent.who is the RelatedPerson                                      | CR   | AuditEvent?<br>agent.who[requester]=RelatedPerson/1                                 | AuditEvent?<br>agent.who[requester]=RelatedPerson/1                               |
| Task                 | If the owner is the RelatedPerson                                          | R    | Task?owner=RelatedPerson/1                                                          |                                                                                   |
