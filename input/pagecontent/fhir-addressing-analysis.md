### Document Purpose

This document analyzes the addressing problem in the FHIR proposal for team-level messaging and proposes a solution to enable team-to-team communication using CareTeam while maintaining individual auditability.

**Related:** See the [Organization Addressing Proposal](fhir-addressing-proposal.html) for the original business requirements and high-level solution overview.

---

### OZO Context and Resource Semantics

### Resource Meanings in OZO:

1. **CareTeam**: Represents all people involved in a **patient's care**
   - Includes both formal (practitioners) and informal (related persons) caregivers
   - Patient-centric: organized around caring for a specific patient

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

### Note to Self: Changes Required

### FSH Profile Changes

### File: `input/fsh/profiles/ozo-communicationrequest.fsh`

**Current constraints to relax:**
```fsh
// CURRENT:
* sender only Reference(OZOPractitioner or OZORelatedPerson)
* recipient only Reference(OZOPractitioner or OZORelatedPerson or OZOCareTeam)

// CHANGE TO:
* sender only Reference(OZOPractitioner or OZORelatedPerson or OZOCareTeam)
* recipient only Reference(OZOPractitioner or OZORelatedPerson or OZOCareTeam)

// KEEP AS IS (no change):
* requester only Reference(OZOPractitioner or OZORelatedPerson)
```

**Rationale:**
- `requester` stays restricted to individuals (auditability - tracks who initiated)
- `sender` now allows CareTeam (provides reply-to address and team-level authorization)
- `recipient` remains unchanged (CareTeam already supported)

### File: `input/fsh/profiles/ozo-communication.fsh`

**Current constraints:**
```fsh
// NO CHANGES NEEDED:
* recipient only Reference(OZOPractitioner or OZORelatedPerson or OZOCareTeam)
* sender only Reference(OZOPractitioner or OZORelatedPerson)
```

**Rationale:**
- `sender` stays restricted to individuals (auditability - tracks who sent each message)
- `recipient` already allows CareTeam (no change needed)
- Individual team member can be tracked separately for display and delete permissions

---

### Documentation Updates Required

### File: `input/pagecontent/interaction-messaging.md`

**Add new section:**
- **Team-to-Team Messaging with CareTeam**
  - Explain when to use CareTeam as sender for team-level authorization
  - Show example: Pharmacy A → Clinic B with CommunicationRequest using CareTeam sender/recipient
  - Document reply-to discovery: read CareTeam from `CommunicationRequest.sender`
  - Explain how individual team members are tracked for auditability

**Update existing examples:**
- Add example showing `CommunicationRequest` with:
  - `requester` = Practitioner (individual who initiated)
  - `sender` = CareTeam (reply-to address with team-level authorization)
  - `recipient` = CareTeam (addressed to team)
- Add example showing `Communication` replies with:
  - `sender` = Practitioner (individual auditability)
  - `recipient` = CareTeam (from CommunicationRequest.sender)

### File: `input/pagecontent/overview.md`

**Update CommunicationRequest description:**
```markdown
The `CommunicationRequest` can use CareTeam as sender for team-level messaging:
- `requester`: Individual who initiated (Practitioner or RelatedPerson) - for auditability
- `sender`: Can be CareTeam to provide reply-to address and team-level authorization
- `recipient`: Can be CareTeam to enable shared inbox pattern for teams
```

**Update Communication description:**
```markdown
The `Communication` sender must remain an individual for auditability:
- `sender`: Individual who sent the message (Practitioner or RelatedPerson) - for auditability
- `recipient`: Can be CareTeam to address messages to all members of a team
- Individual team member tracked separately for display and delete permissions
```

---

### Examples to Add

### File: `input/fsh/instances/communicationrequest-team-example.fsh` (NEW)

```fsh
Instance: CommunicationRequest-Pharmacy-to-Clinic
InstanceOf: OZOCommunicationRequest
Title: "Example: Pharmacy to Clinic Team-Level Communication Request"
Description: "Shows a CommunicationRequest from a pharmacy team to a clinic team using CareTeam addressing"
* status = #active
* subject = Reference(Patient/example-patient)
* requester = Reference(Practitioner/pharmacy-practitioner-a1)
* sender = Reference(CareTeam/pharmacy-a)
* recipient = Reference(CareTeam/clinic-b)
* payload[0].contentString = "Can you review this patient's medication list for potential interactions?"
```

### File: `input/fsh/instances/communication-team-reply-example.fsh` (NEW)

```fsh
Instance: Communication-Clinic-Reply
InstanceOf: OZOCommunication
Title: "Example: Clinic Reply to Team-Level Message"
Description: "Shows a Communication reply from clinic practitioner to pharmacy team"
* status = #completed
* basedOn = Reference(CommunicationRequest/CommunicationRequest-Pharmacy-to-Clinic)
* sender = Reference(Practitioner/clinic-practitioner-b1)
* recipient = Reference(CareTeam/pharmacy-a)
* payload[0].contentString = "I've reviewed the medications and will send my recommendations today"
```

---

### Migration Notes

- **Backward compatible:** Existing individual-to-individual messaging patterns remain unchanged
- **New capability:** CareTeam-level messaging with team authorization now supported
- **Team authorization:** CareTeam as sender provides authorization for message management
- **Auditability preserved:** Individual practitioners tracked via requester field and Communication.sender

---

### Comparison with Original Proposal:

| Aspect | Original Proposal | Recommended Solution (CareTeam as Sender) |
|--------|------------------|-------------------------------------------|
| Addressing mechanism | Practitioner as sender with extension | CareTeam as sender in CommunicationRequest |
| Team authorization | Unclear | CareTeam gives team-level authorization |
| Individual auditability | Via extension | Communication.sender = Practitioner |
| Reply-to discovery | Complex | Simple (read from CommunicationRequest.sender) |
| Custom extensions | Yes (for tracking team) | Not required for basic flow |
| Profile changes needed | Yes | Yes (allow CareTeam in sender) |

This solution provides **team-level authorization** while maintaining **individual auditability** through proper use of requester and sender fields.
