# Organization Addressing Proposal

## Business Goal

Enable pharmacies and clinics to have **organization-level visibility** of all incoming and outgoing FHIR-based messages in OZO, so that multiple staff members can collaborate and respond to communications, instead of restricting messages to individual practitioners. 

## Requirements

Messages must remain compliant with OZO's restrictions 

(Practitioner/RelatedPerson/CareTeam only). 

All members of a pharmacy (or clinic) should be able to see messages sent to their institution. 

All members of a pharmacy (or clinic) should be able to respond to any messages. It must still be possible to track the **exact person** (Practitioner) who initiated or responded to a message. 

The solution must remain compatible with **OZO FHIR** and **HAPI FHIR**. 

## Current Limitation

In OZO, Communication.sender and CommunicationRequest.requester must be of type **Practitioner** or **RelatedPerson**. 

Similarly, recipient is restricted to **Practitioner** or **CareTeam**. 

This prevents messages from being directly addressed to an **Organization** (e.g., Pharmacy A, Clinic X). 

As a result: 

If messages are addressed only to **Practitioners**, they are visible only to the individual, not the whole organization. 

Colleagues from the same pharmacy cannot see each other’s conversations, which breaks the “shared inbox” requirement. 

## Proposed Solution: Use CareTeam as Proxy for Organization

Define a **CareTeam** resource for each organization (e.g., *Pharmacy A*). 

Use **CareTeam** as the recipient in **Communication** and **CommunicationRequest** resources.  
Keep the actual **Practitioner** as the sender (for Communication) and requester (for CommunicationRequest) to preserve auditability. 

*Optionally:* 

add all pharmacists or staff members of that organization as participants in the CareTeam. 

link the CareTeam back to its managing Organization for traceability.

## Messaging Flow

### Actors 

**Pharmacy A (Organization)** 

**Practitioner A1** (pharmacist) 

**CareTeam A** (all pharmacists in Pharmacy A) 

**Clinic B (Organization)** 

**Practitioner B1** (general practitioner) 

**CareTeam B** (all general practitioners in Clinic B)

### Step-by-Step Flow

Step 1: Pharmacy A send a message to Clinic B 

**Practitioner A1** creates a CommunicationRequest . 

sender \= CareTeam A with extension \= Practitioner A1 

recipient \= CareTeam B . 

This ensures **all doctors from Clinic B** see the request and also we are aware of the **pharmacist that sent the message** via the extension property. 

Step 2: Clinic B picks it up 

Any doctor in Clinic B (e.g., Practitioner B1) replies with a Communication . sender \= Practitioner B1 

recipient \= CareTeam A . 

This ensure **all pharmacist from Pharmacy A** see the response and also are aware of **the general practitioner that responded**. 

Step 4: Ongoing Conversation 

Conversation continues as a **thread of Communication resources**: 

Always partOf the original CommunicationRequest .  
Always inResponseTo the previous Communication if needed. sender \= individual practitioner 

recipient \= CareTeam of the other side.