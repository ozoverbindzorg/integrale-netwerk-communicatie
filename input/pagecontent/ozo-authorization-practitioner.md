### Authorization rules of the Practitioner access

This table describes the access rules for a Practitioner role in a healthcare system, showing:
1. **Entities**: Various healthcare resources like Patient, CareTeam, Communication, etc.
2. **Access conditions**: When a Practitioner can access specific resources
3. **CRUD permissions**: Whether they can Create (C) and/or Read (R) the resources
4. **Validation queries**: The FHIR search queries used to validate read or create access


| Entity               | As Practitioner                                                                    | CRUD | Read validation                                                                    | Create validation                                                                |
|----------------------|------------------------------------------------------------------------------------|------|------------------------------------------------------------------------------------|----------------------------------------------------------------------------------|
| RelatedPerson        | If the RelatedPerson is a member the same CareTeam                                 | R    | RelatedPerson?<br>_has:CareTeam:participant:participant=Practitioner/1             |                                                                                  |                   |
| Patient              | If the Practitioner is a member of a CareTeam where the Patient = CareTeam.patient | R    | Patient?<br>_has:CareTeam:patient:participant=Practitioner/1                       |                                                                                  |
| Practitioner         | If the Practitioner is a member the same CareTeam                                  | R    | RelatedPerson?<br>_has:CareTeam:participant:participant=Practitioner/1             |                                                                                  |
| CareTeam             | If the Practitioner is a participant of the CareTeam                               | R    | CareTeam?<br>participant:Practitioner=Practitioner/1                               |                                                                                  |
| CommunicationRequest | If the Practitioner or a CareTeam of the Practitioner is a thread party: `recipient` or `extension[senderCareTeam]` | CR   | CommunicationRequest?<br>participant=Practitioner/1,CareTeam/1                     | CommunicationRequest?requester=Practitioner/1; `extension[senderCareTeam]` is an organizational CareTeam of the Practitioner and not in `recipient` |
| Communication        | If the part-of matches the rule above                                              | CR   | Communication?<br>part-of:CommunicationRequest.participant=Practitioner/1,CareTeam/1 | Communication?sender=Practitioner/1 AND partOf is a thread the Practitioner is a party of; `extension[senderCareTeam]` names the Practitioner's team in that thread when they have one |
| AuditEvent           | If the agent.who is the Practitioner                                               | CR   | AuditEvent?<br>agent.who[requester]=Practitioner/1                                 | AuditEvent?<br>agent.who[requester]=Practitioner/1; on a read receipt in a team thread `agent.extension[careTeam]` names the Practitioner's team |
| Task                 | If the owner is the Practitioner or an organizational CareTeam of the Practitioner | R    | Task?owner=Practitioner/1,CareTeam/1                                               |                                                                                  |
