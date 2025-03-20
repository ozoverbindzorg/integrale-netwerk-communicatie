### Authorization rules of the Practitioner access

This table describes the access rules for a Practitioner role in a healthcare system, showing:
1. **Entities**: Various healthcare resources like Patient, CareTeam, Communication, etc.
2. **Access conditions**: When a Practitioner can access specific resources
3. **CRUD permissions**: Whether they can Create (C) and/or Read (R) the resources
4. **Validation queries**: The FHIR search queries used to validate read or create access


| Entity               | As Practitioner                                                                    | CRUD | Read validation                                                                    | Create validation                                                                |
|----------------------|------------------------------------------------------------------------------------|------|------------------------------------------------------------------------------------|----------------------------------------------------------------------------------|
| RelatedPerson        | If the Practitioner is a member the same CareTeam                                  | R    | RelatedPerson?<br>_has:CareTeam:participant:participant=Practitioner/1             |                                                                                  |                   |
| Patient              | If the Practitioner is a member of a CareTeam where the Patient = CareTeam.patient | R    | Patient?<br>_has:CareTeam:patient:participant=Practitioner/1                       |                                                                                  |
| Practitioner         | If the identity matches                                                            | R    | Practitioner?<br><br>identifier=system\|user_id                                    |                                                                                  |
| CareTeam             | If the Practitioner is a participant of the CareTeam                               | R    | CareTeam?<br>participant:Practitioner=Practitioner/1                               |                                                                                  |
| CommunicationRequest | If the Practitioner or the CareTeam of the Practitioner is the recipient           | CR   | CommunicationRequest?<br>recipient=Practitioner/1,CareTeam/1                       | CommunicationRequest?requester=Practitioner/1                                    |
| Communication        | If the part-of matches the rule above                                              | CR   | Communication?<br>part-of:CommunicationRequest.recipient=Practitioner/1,CareTeam/1 | Communication?sender=Practitioner/1 AND Communication.recipient share a CareTeam |
| AuditEvent           | If the agent.who is the Practitioner                                               | CR   | AuditEvent?<br>agent.who[requester]=Practitioner/1                                 | AuditEvent?<br>agent.who[requester]=Practitioner/1                               |
| Task                 | If the owner is the Practitioner                                                   | R    | Task?owner=RelatedPerson/1                                                         |                                                                                  |
