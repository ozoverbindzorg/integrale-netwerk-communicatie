### Document Purpose

This document analyzes the addressing problem in the FHIR proposal for team-level messaging and proposes a solution to enable team-to-team communication using CareTeam while maintaining individual auditability.

**Related:** See the [Organization Addressing Proposal](fhir-addressing-proposal.html) for the original business requirements and high-level solution overview.

---

### OZO Context and Resource Semantics

### Resource Meanings in OZO:

1. **CareTeam**: OZO defines two CareTeam profiles:
   - **OZOCareTeam**: Patient care network — includes practitioners and informal caregivers, bound to a specific patient
   - **OZOOrganizationalCareTeam**: Organizational team — represents a department or organizational unit (e.g., pharmacy, clinic) for team-to-team messaging, not bound to a patient

2. **CommunicationRequest**: Represents a **conversation thread** (Current Pattern)
   - Includes all people involved in the conversation
   - Contains the initial message as payload
   - Functions as both: conversation initiator AND first message container

3. **Communication**: Represents a **reply** in the conversation
   - References the CommunicationRequest via `basedOn`
   - Contains the reply message as payload
   - Can reference previous Communications via `inResponseTo`

### Key Observations

### 1. **CommunicationRequest has a distinct `requester` field**
- FHIR R4 allows: Practitioner, PractitionerRole, **Organization**, Patient, RelatedPerson, Device
- OZO restricts to: Practitioner, RelatedPerson
- **Important:** `requester` can be different from `sender`

### 2. **Both resources allow Organization in sender**
- FHIR R4 `sender` allows: Device, **Organization**, Patient, Practitioner, PractitionerRole, RelatedPerson, HealthcareService
- OZO restricts `sender` to: Practitioner, RelatedPerson (excludes Organization!)

### 3. **Both resources allow Organization in recipient**
- FHIR R4 `recipient` allows: Device, **Organization**, Patient, Practitioner, PractitionerRole, RelatedPerson, HealthcareService, Group, **CareTeam**, Endpoint
- OZO restricts `recipient` to: Practitioner, RelatedPerson, CareTeam (excludes Organization!)

### 4. **CareTeam is already allowed as recipient in OZO**
- This is why the proposal suggests using CareTeam as proxy for Organization
- CareTeam is NOT allowed as sender/requester in OZO

---

### Analysis: The Addressing Problem Revisited

### Standard FHIR R4 Solution (If OZO didn't have constraints):

```
Step 1: Pharmacy sends request
CommunicationRequest:
  requester = Practitioner/A1           ← Individual who initiated (auditability)
  sender = Organization/Pharmacy-A      ← Reply-to address
  recipient = Organization/Clinic-B     ← Addressed to organization
  payload = "Can you review patient's medication?"

Step 2: Clinic replies
Communication:
  sender = Practitioner/B1              ← Individual responds (auditability)
  recipient = Organization/Pharmacy-A   ← Read from CommunicationRequest.sender
  basedOn = CommunicationRequest/...
  payload = "Yes, I'll review it today"
```

**Why this works:**
- `requester` tracks the individual who initiated (auditability)
- `sender` in CommunicationRequest provides the Organization reply-to address
- `sender` in Communication tracks the individual who responds (auditability)
- No discovery needed - the information is in the CommunicationRequest

### Current OZO Constraints Problem:

```
Step 1: Pharmacy sends request
CommunicationRequest:
  requester = Practitioner/A1          ← Must be Practitioner (OZO constraint)
  sender = Practitioner/A1             ← Must be Practitioner (OZO constraint)
  recipient = CareTeam/B               ← Using CareTeam as proxy

Step 2: Clinic needs to reply
Communication:
  sender = Practitioner/B1
  recipient = ??? ← No Organization in original request to reply to!
```

**The issue:**
- OZO constraints prevent Organization in `requester` field
- Cannot determine which Organization/CareTeam to reply to
- Only have individual Practitioner reference

---

### Proposed Solution: Allow CareTeam as Sender

*Note: This is the recommended solution. See [Detailed Analysis](#detailed-analysis) below for complete specification.*

### Constraint Changes:

### **CommunicationRequest:**
- `requester`: **Keep as Practitioner | RelatedPerson** (to track individual who initiated the conversation)
- `sender`: Allow **CareTeam** (in addition to Practitioner, RelatedPerson)
- `recipient`: **Keep as Practitioner | RelatedPerson | CareTeam** (no change)

### **Communication:**
- `sender`: Allow **CareTeam** or **Practitioner | RelatedPerson** (CareTeam for team-level authorization, individual for auditability)
- `recipient`: **Keep as Practitioner | RelatedPerson | CareTeam** (no change)

### Rationale:

1. **Team-level authorization**:
   - CareTeam as sender gives the team authorization to archive and delete messages
   - All team members can see and respond to messages sent to their CareTeam

2. **Individual auditability preserved**:
   - `CommunicationRequest.requester` tracks who initiated the conversation
   - Individual Practitioner who sent each message can be tracked separately (via extension or by using Practitioner as Communication.sender)
   - Every message has an identifiable person for audit purposes

3. **Shared inbox pattern enabled**:
   - CareTeam as recipient enables "shared inbox" for pharmacies, clinics, etc.
   - All team members can collaborate on responses
   - Reply-to address is clear: use the CareTeam from the original message

### Message Flow Example:

```
Step 1: Pharmacy A initiates conversation with first message
CommunicationRequest:
  requester = Practitioner/A1              (individual who initiated - auditability)
  sender = CareTeam/Pharmacy-A             (team is thread owner - reply-to address)
  recipient = CareTeam/Clinic-B            (addressed to team)
  payload = "Can you review patient's medication?"  (initial message)
  subject = Patient/123

Step 2: Practitioner B1 from Clinic B replies
Communication:
  sender = Practitioner/B1                 (individual responds for auditability)
  recipient = CareTeam/Pharmacy-A          (read from CommunicationRequest.sender)
  basedOn = CommunicationRequest/...       (links to thread)
  payload = "Yes, I'll review and respond by tomorrow"

Step 3: Another practitioner A2 from Pharmacy A follows up
Communication:
  sender = Practitioner/A2                 (different person from same team)
  recipient = CareTeam/Clinic-B            (continue to same team)
  basedOn = CommunicationRequest/...       (links to thread)
  inResponseTo = Communication/step2       (reply to previous message)
  payload = "Thank you for the quick response"
```

### Key Benefits:

1. ✅ **Team-level authorization**: CareTeam as sender gives team authorization to manage messages
2. ✅ **Individual auditability**: Individual Practitioner tracked separately for each message
3. ✅ **Shared visibility**: All team members see messages to their CareTeam
4. ✅ **Clear reply-to address**: Read CareTeam from CommunicationRequest.sender
5. ✅ **Thread management**: CommunicationRequest defines conversation participants
6. ✅ **Standards compliant**: Uses standard FHIR resource types

### Constraint Summary:

| Resource | Field | Allowed Types | Note |
|----------|-------|---------------|------|
| CommunicationRequest | requester | Practitioner, RelatedPerson | **No change** - tracks individual who initiated |
| CommunicationRequest | sender | Practitioner, RelatedPerson, CareTeam | **CareTeam added** - team-level reply-to address |
| CommunicationRequest | recipient | Practitioner, RelatedPerson, CareTeam | **No change** |
| Communication | sender | Practitioner, RelatedPerson | **No change** - must be individual for auditability |
| Communication | recipient | Practitioner, RelatedPerson, CareTeam | **No change** |

---

### Detailed Analysis

### Overview

**Core Principle:** Allow CareTeam as sender in both CommunicationRequest and Communication, while maintaining individual auditability through the requester field and tracking the individual team member separately.

### The Problem This Solution Solves

The original OZO constraints created an impossible situation:
- Teams (pharmacies, clinics) need to be addressable and need team-level authorization for message management
- OZO restrictions prevented CareTeam in sender field
- Individual practitioners needed to be tracked for auditability
- No clear way to give team-level authorization while maintaining individual accountability

### Solution Architecture

### Part 1: CommunicationRequest Changes

**Relax constraints to allow CareTeam:**
```
CommunicationRequest.requester: Practitioner | RelatedPerson (NO CHANGE - must be individual)
CommunicationRequest.sender: Practitioner | RelatedPerson | CareTeam
CommunicationRequest.recipient: Practitioner | RelatedPerson | CareTeam (NO CHANGE)
```

**Purpose:**
- `requester` identifies the individual who initiated (auditability)
- `sender` can be CareTeam (reply-to address for the conversation, team-level authorization)
- `recipient` remains CareTeam-capable (shared inbox for receiving team)

### Part 2: Communication Changes

**Keep constraints as-is (individual sender required):**
```
Communication.sender: Practitioner | RelatedPerson (NO CHANGE - must be individual)
Communication.recipient: Practitioner | RelatedPerson | CareTeam (NO CHANGE)
```

**Purpose:**
- CareTeams can receive messages (shared inbox)
- Sender must be an individual (preserves auditability)
- Clear audit trail: every message has an identifiable person as sender
- Individual team member can be tracked for display and delete permissions

### Addressing Flow (How Reply-To Works)

### Scenario: Pharmacy A → Clinic B

**Step 1: Thread Initiation**
```fsh
Instance: thread-pharmacy-to-clinic
InstanceOf: CommunicationRequest
* status = #active
* subject = Reference(Patient/123)
* requester = Reference(Practitioner/A1)          // ← Individual who initiated
* sender = Reference(CareTeam/Pharmacy-A)         // ← Reply-to address (team authorization)
* recipient = Reference(CareTeam/Clinic-B)
* payload[0].contentString = "Can you review the patient's medication list?"
```

**Step 2: Reply from Clinic (Practitioner B1)**
```fsh
Instance: msg-1-pharmacy-question
InstanceOf: Communication
* status = #completed
* basedOn = Reference(CommunicationRequest/thread-pharmacy-to-clinic)
* sender = Reference(Practitioner/A1)              // ← Individual auditability
* recipient = Reference(CareTeam/Clinic-B)         // ← From CommunicationRequest.recipient
* payload[0].contentString = "Can you review the patient's medication list?"
```

**Application Logic for Reply-To Discovery:**
1. Read the Communication's `basedOn` reference
2. Fetch the CommunicationRequest
3. Identify the sender's CareTeam:
   - If `CommunicationRequest.sender` is CareTeam → use that as reply recipient
   - This provides the reply-to address for the conversation thread

**Step 3: Reply (Practitioner B1)**
```fsh
Instance: msg-2-clinic-response
InstanceOf: Communication
* status = #completed
* basedOn = Reference(CommunicationRequest/thread-pharmacy-to-clinic)
* inResponseTo = Reference(Communication/msg-1-pharmacy-question)
* sender = Reference(Practitioner/B1)              // ← Individual auditability
* recipient = Reference(CareTeam/Pharmacy-A)       // ← From CommunicationRequest.sender
* payload[0].contentString = "Yes, I'll review it today and follow up by EOD"
```

**Step 4: Follow-up (Different Practitioner A2)**
```fsh
Instance: msg-3-pharmacy-followup
InstanceOf: Communication
* status = #completed
* basedOn = Reference(CommunicationRequest/thread-pharmacy-to-clinic)
* inResponseTo = Reference(Communication/msg-2-clinic-response)
* sender = Reference(Practitioner/A2)              // ← Different person, same team
* recipient = Reference(CareTeam/Clinic-B)         // ← Continue to same team
* payload[0].contentString = "Thank you for the quick response!"
```

### Query Patterns for Applications

### For CareTeam Members: "Show me messages to my team"

```
GET /Communication?recipient=CareTeam/Pharmacy-A&_include=Communication:based-on
```

Returns all Communications where recipient is the CareTeam, plus their parent CommunicationRequests.

### For Practitioners: "Show me my sent messages"

```
GET /Communication?sender=Practitioner/A1
```

Returns all Communications sent by this individual.

### For Thread View: "Show me all messages in a conversation"

```
GET /Communication?based-on=CommunicationRequest/thread-pharmacy-to-clinic
  &_sort=sent
```

Returns chronologically sorted thread.

---

### Implementation Status

> **All changes below have been implemented.** This section documents what was done for reference.

### What Was Implemented

Since FHIR R4 `CommunicationRequest.sender` does not allow CareTeam references, the solution uses an **extension** (`OZOSenderCareTeam`) instead of relaxing the sender constraint directly.

### FSH Profile Changes

**File: `input/fsh/profiles/ozo-communicationrequest.fsh`**
- `sender` remains restricted to `OZOPractitioner | OZORelatedPerson` (individual sender)
- `requester` remains restricted to `OZOPractitioner | OZORelatedPerson` (individual who initiated)
- Added `OZOSenderCareTeam` extension (0..1) for CareTeam as reply-to address
- `recipient` unchanged: `OZOPractitioner | OZORelatedPerson | OZOCareTeam`

**File: `input/fsh/profiles/ozo-communication.fsh`**
- No changes needed. `sender` = individual, `recipient` allows CareTeam.

### Documentation Updates

- **`interaction-messaging.md`**: Added "Team-to-Team Messaging" section with examples using `extension[senderCareTeam]`
- **`overview.md`**: Updated CommunicationRequest field table and team-level messaging description

### Examples Added

- `communicationrequest-team-to-team.fsh` - `Pharmacy-to-Clinic` with `senderCareTeam` extension
- `communication-pharmacy-initial-message.fsh` - Initial message from pharmacy practitioner
- `communication-clinic-response-to-pharmacy.fsh` - Clinic reply to pharmacy team
- `communication-pharmacy-followup-by-pieter.fsh` - Follow-up from different team member
- `careteam-pharmacy-a.fsh` and `careteam-clinic-b.fsh` - Team CareTeam resources

### Key Design Decision

The analysis above proposed adding CareTeam directly to `CommunicationRequest.sender`. During implementation, it was discovered that FHIR R4 does not allow CareTeam in that field. The `OZOSenderCareTeam` extension achieves the same goal while remaining FHIR R4 compliant. All sender fields remain restricted to individuals, preserving auditability.
