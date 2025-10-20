### Document Purpose

This document analyzes the addressing problem in the FHIR proposal for organization-level messaging and proposes a solution to enable organization-to-organization communication while maintaining individual auditability.

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

### Proposed Solution: Allow Organization Addressing

*Note: This is the recommended solution. See [Detailed Analysis](#detailed-analysis) below for complete specification.*

### Constraint Changes:

### **CommunicationRequest:**
- `requester`: **Keep as Practitioner | RelatedPerson** (to track individual who initiated the conversation)
- `sender`: Allow **Organization** (in addition to Practitioner, RelatedPerson)
- `recipient`: Allow **Organization** (in addition to Practitioner, RelatedPerson, CareTeam)

### **Communication:**
- `sender`: **Keep as Practitioner | RelatedPerson** (must be an individual for auditability)
- `recipient`: Allow **Organization** (in addition to Practitioner, RelatedPerson, CareTeam)

### Rationale:

1. **Individual auditability preserved**:
   - `CommunicationRequest.requester` tracks who initiated the conversation
   - `Communication.sender` tracks who sent each message
   - Every message has an identifiable person as sender

2. **Organization addressing enabled**:
   - `CommunicationRequest.sender` can be Organization (reply-to address)
   - `CommunicationRequest.recipient` and `Communication.recipient` can be Organization
   - Enables "shared inbox" pattern for pharmacies, clinics, etc.

3. **Clear separation of concerns**:
   - Use Organization for organizational messaging (not CareTeam)
   - CareTeam remains for patient care coordination

### Message Flow Example:

```
Step 1: Pharmacy A initiates conversation with first message
CommunicationRequest:
  requester = Practitioner/A1              (individual who initiated - auditability)
  sender = Organization/Pharmacy-A         (organization is thread owner - reply-to address)
  recipient = Organization/Clinic-B        (addressed to organization)
  payload = "Can you review patient's medication?"  (initial message)
  subject = Patient/123

Step 2: Practitioner B1 from Clinic B replies
Communication:
  sender = Practitioner/B1                 (individual responds)
  recipient = Organization/Pharmacy-A      (read from CommunicationRequest.sender)
  basedOn = CommunicationRequest/...       (links to thread)
  payload = "Yes, I'll review and respond by tomorrow"

Step 3: Another practitioner A2 from Pharmacy A follows up
Communication:
  sender = Practitioner/A2                 (different person from same organization)
  recipient = Organization/Clinic-B        (continue to same organization)
  basedOn = CommunicationRequest/...       (links to thread)
  inResponseTo = Communication/step2       (reply to previous message)
  payload = "Thank you for the quick response"
```

### Key Benefits:

1. ✅ **Clear addressing**: Organizations can be senders and recipients
2. ✅ **Individual auditability**: Every message is from an identifiable person
3. ✅ **Shared visibility**: All organization members see messages to their organization
4. ✅ **No extensions needed**: Uses standard FHIR fields
5. ✅ **Audit trail preserved**: sender field always identifies the actual person
6. ✅ **Reply-to address**: Read from CommunicationRequest.sender or CommunicationRequest.recipient
7. ✅ **Thread management**: CommunicationRequest defines conversation participants

### Constraint Summary:

| Resource | Field | Allowed Types | Note |
|----------|-------|---------------|------|
| CommunicationRequest | requester | Practitioner, RelatedPerson | **No change** - tracks individual who initiated |
| CommunicationRequest | sender | Practitioner, RelatedPerson, Organization | Organization = reply-to address |
| CommunicationRequest | recipient | Practitioner, RelatedPerson, CareTeam, Organization | - |
| Communication | sender | Practitioner, RelatedPerson | **No change** - must be individual |
| Communication | recipient | Practitioner, RelatedPerson, CareTeam, Organization | - |

---

### Alternative Solutions (For Reference)

### **Option 1: Extend OZO constraints to allow CareTeam in sender**

**Change:**
```
Current OZO:
  CommunicationRequest.sender: Practitioner | RelatedPerson
  CommunicationRequest.requester: Practitioner | RelatedPerson

Proposed OZO:
  CommunicationRequest.sender: Practitioner | RelatedPerson | CareTeam
  CommunicationRequest.requester: Practitioner | RelatedPerson
```

**Message Flow:**
```
CommunicationRequest:
  requester = Practitioner/A1  (audit: who initiated)
  sender = CareTeam/A          (reply-to address)
  recipient = CareTeam/B       (who should respond)

Communication (response):
  sender = Practitioner/B1     (audit: who responded)
  recipient = CareTeam/A       (from CommunicationRequest.sender)
  basedOn = CommunicationRequest/...

Communication (follow-up):
  sender = CareTeam/A          (logical sender is the team)
  recipient = CareTeam/B       (from previous Communication.sender's CareTeam)
  inResponseTo = Communication/...
```

**OR for follow-up maintain individual:**
```
Communication (follow-up):
  sender = Practitioner/A2     (different person responds)
  recipient = CareTeam/B       (keep replying to same team)
  inResponseTo = Communication/...
```

**Problem:** Still need to derive sender's CareTeam for follow-ups from individuals

---

### **Option 2: Keep all Communication.sender as individuals, add extension**

Add `representedCareTeam` extension:

```
CommunicationRequest:
  requester = Practitioner/A1
  recipient = CareTeam/B
  extension[representedCareTeam] = CareTeam/A

Communication:
  sender = Practitioner/B1
  recipient = CareTeam/A  (from extension)
  basedOn = CommunicationRequest/...
  extension[representedCareTeam] = CareTeam/B
```

---

### Summary Table: Comparison of Alternative Approaches

*Note: These are early exploratory options. The recommended solution (Solution B: Organization + Payload Rules) is described in the next section.*

| Approach | Pros | Cons | Requires Profile Change |
|----------|------|------|------------------------|
| **Allow Organization in requester** | Standard FHIR pattern | Still need Organization→CareTeam mapping | Yes - requester field |
| **Allow CareTeam in sender** | Clean reply-to pattern, sender field provides address | Semantic confusion: CareTeam for org messaging | Yes - sender field |
| **Extension for reply-to** | No profile constraint changes, explicit | Custom extension, applications must support | No - only extension |

---

### Final Recommendation

**Best approach: Allow Organization Addressing**

The proposed solution uses Organization directly for organizational messaging, while maintaining individual auditability through the requester and sender fields.

---

### Detailed Analysis

### Overview

**Core Principle:** Allow Organization as a participant type, while maintaining individual auditability through proper use of requester and sender fields.

### The Problem This Solution Solves

The original OZO constraints created an impossible situation:
- Organizations need to be addressable (pharmacies, clinics want shared inboxes)
- OZO restrictions prevented Organization in sender/recipient fields
- CareTeam was designed for patient care coordination, not organizational messaging
- No clear way to reply to an organization without complex workarounds

### Solution Architecture

### Part 1: CommunicationRequest Changes

**Relax constraints to allow Organization:**
```
CommunicationRequest.requester: Practitioner | RelatedPerson (NO CHANGE - must be individual)
CommunicationRequest.sender: Practitioner | RelatedPerson | Organization
CommunicationRequest.recipient: Practitioner | RelatedPerson | CareTeam | Organization
```

**Purpose:**
- `requester` identifies the individual who initiated (auditability)
- `sender` can be Organization (reply-to address for the conversation)
- `recipient` can be Organization (shared inbox for receiving organization)

### Part 2: Communication Changes

**Relax recipient constraint, keep sender as individual:**
```
Communication.sender: Practitioner | RelatedPerson (NO CHANGE - must be individual)
Communication.recipient: Practitioner | RelatedPerson | CareTeam | Organization
```

**Purpose:**
- Organizations can receive messages (shared inbox)
- Sender must be an individual (preserves auditability)
- Clear audit trail: every message has an identifiable person as sender

### Addressing Flow (How Reply-To Works)

### Scenario: Pharmacy A → Clinic B

**Step 1: Thread Initiation**
```fsh
Instance: thread-pharmacy-to-clinic
InstanceOf: CommunicationRequest
* status = #active
* subject = Reference(Patient/123)
* requester = Reference(Practitioner/A1)          // ← Individual who initiated
* sender = Reference(Organization/Pharmacy-A)     // ← Reply-to address
* recipient = Reference(Organization/Clinic-B)
* payload[0].contentString = "Can you review the patient's medication list?"
```

**Step 2: Reply from Clinic (Practitioner B1)**
```fsh
Instance: msg-1-pharmacy-question
InstanceOf: Communication
* status = #completed
* basedOn = Reference(CommunicationRequest/thread-pharmacy-to-clinic)
* sender = Reference(Practitioner/A1)              // ← Individual auditability
* recipient = Reference(Organization/Clinic-B)     // ← From CommunicationRequest.recipient
* payload[0].contentString = "Can you review the patient's medication list?"
```

**Application Logic for Reply-To Discovery:**
1. Read the Communication's `basedOn` reference
2. Fetch the CommunicationRequest
3. Identify the sender's organization:
   - If `CommunicationRequest.sender` is Organization → use that as reply recipient
   - Otherwise, look at the current Communication's sender's organization

**Step 3: Reply (Practitioner B1)**
```fsh
Instance: msg-2-clinic-response
InstanceOf: Communication
* status = #completed
* basedOn = Reference(CommunicationRequest/thread-pharmacy-to-clinic)
* inResponseTo = Reference(Communication/msg-1-pharmacy-question)
* sender = Reference(Practitioner/B1)              // ← Individual auditability
* recipient = Reference(Organization/Pharmacy-A)   // ← From CommunicationRequest.sender
* payload[0].contentString = "Yes, I'll review it today and follow up by EOD"
```

**Step 4: Follow-up (Different Practitioner A2)**
```fsh
Instance: msg-3-pharmacy-followup
InstanceOf: Communication
* status = #completed
* basedOn = Reference(CommunicationRequest/thread-pharmacy-to-clinic)
* inResponseTo = Reference(Communication/msg-2-clinic-response)
* sender = Reference(Practitioner/A2)              // ← Different person, same org
* recipient = Reference(Organization/Clinic-B)     // ← Continue to same org
* payload[0].contentString = "Thank you for the quick response!"
```

### Query Patterns for Applications

### For Organization Members: "Show me messages to my organization"

```
GET /Communication?recipient=Organization/Pharmacy-A&_include=Communication:based-on
```

Returns all Communications where recipient is the organization, plus their parent CommunicationRequests.

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
// CURRENT (remove these restrictions):
* sender only Reference(OZOPractitioner or OZORelatedPerson)
* recipient only Reference(OZOPractitioner or OZORelatedPerson or OZOCareTeam)

// CHANGE TO:
* sender only Reference(OZOPractitioner or OZORelatedPerson or OZOOrganization)
* recipient only Reference(OZOPractitioner or OZORelatedPerson or OZOCareTeam or OZOOrganization)

// KEEP AS IS (no change):
* requester only Reference(OZOPractitioner or OZORelatedPerson)
```

**Rationale:**
- `requester` stays restricted to individuals (auditability - tracks who initiated)
- `sender` now allows Organization (provides reply-to address for organizational messaging)
- `recipient` now allows Organization (enables shared inbox pattern)

### File: `input/fsh/profiles/ozo-communication.fsh`

**Current constraints to relax:**
```fsh
// CURRENT (remove this restriction):
* recipient only Reference(OZOPractitioner or OZORelatedPerson or OZOCareTeam)

// CHANGE TO:
* recipient only Reference(OZOPractitioner or OZORelatedPerson or OZOCareTeam or OZOOrganization)

// KEEP AS IS (no change):
* sender only Reference(OZOPractitioner or OZORelatedPerson)
```

**Rationale:**
- `sender` stays restricted to individuals (auditability - tracks who sent each message)
- `recipient` now allows Organization (messages can be addressed to organizations)

---

### Documentation Updates Required

### File: `input/pagecontent/interaction-messaging.md`

**Add new section:**
- **Organization-to-Organization Messaging**
  - Explain when to use Organization vs individual addressing
  - Show example: Pharmacy A → Clinic B with CommunicationRequest using Organization sender/recipient
  - Document reply-to discovery: read Organization from `CommunicationRequest.sender`

**Update existing examples:**
- Add example showing `CommunicationRequest` with:
  - `requester` = Practitioner (individual who initiated)
  - `sender` = Organization (reply-to address)
  - `recipient` = Organization (addressed to organization)
- Add example showing `Communication` replies addressed to Organization

### File: `input/pagecontent/overview.md`

**Update CommunicationRequest description:**
```markdown
The `CommunicationRequest` can now address Organizations directly:
- `requester`: Individual who initiated (Practitioner or RelatedPerson) - for auditability
- `sender`: Can be Organization to provide reply-to address for organizational conversations
- `recipient`: Can be Organization to enable shared inbox pattern for pharmacies, clinics, etc.
```

**Update Communication description:**
```markdown
The `Communication` sender must remain an individual, but can be addressed to Organizations:
- `sender`: Individual who sent the message (Practitioner or RelatedPerson) - for auditability
- `recipient`: Can be Organization to address messages to all members of an organization
```

**Add clarification:**
- Distinguish between CareTeam (patient care coordination) and Organization (organizational messaging)
- CareTeam is for the clinical team caring for a specific patient
- Organization is for facility-level messaging (e.g., pharmacy-to-clinic communication)

---

### Examples to Add

### File: `input/fsh/instances/communicationrequest-org-example.fsh` (NEW)

```fsh
Instance: CommunicationRequest-Pharmacy-to-Clinic
InstanceOf: OZOCommunicationRequest
Title: "Example: Pharmacy to Clinic Organization-Level Communication Request"
Description: "Shows a CommunicationRequest from a pharmacy to a clinic using Organization addressing"
* status = #active
* subject = Reference(Patient/example-patient)
* requester = Reference(Practitioner/pharmacy-practitioner-a1)
* sender = Reference(Organization/pharmacy-a)
* recipient = Reference(Organization/clinic-b)
* payload[0].contentString = "Can you review this patient's medication list for potential interactions?"
```

### File: `input/fsh/instances/communication-org-reply-example.fsh` (NEW)

```fsh
Instance: Communication-Clinic-Reply
InstanceOf: OZOCommunication
Title: "Example: Clinic Reply to Organization-Level Message"
Description: "Shows a Communication reply from clinic practitioner to pharmacy organization"
* status = #completed
* basedOn = Reference(CommunicationRequest/CommunicationRequest-Pharmacy-to-Clinic)
* sender = Reference(Practitioner/clinic-practitioner-b1)
* recipient = Reference(Organization/pharmacy-a)
* payload[0].contentString = "I've reviewed the medications and will send my recommendations today"
```

---

### Migration Notes

- **Backward compatible:** Existing individual-to-individual messaging patterns remain unchanged
- **New capability:** Organization-level messaging now supported without workarounds
- **Clear distinction:** CareTeam for patient care, Organization for facility messaging
- **Auditability preserved:** All messages still track individual actors via requester/sender fields

---

### Comparison with Original Proposal:

| Aspect | Original Proposal (CareTeam Proxy) | Recommended Solution (Organization Addressing) |
|--------|-----------------------------------|-----------------------------------------------|
| Addressing mechanism | CareTeam as proxy for Organization | Organization directly |
| Sender auditability | Extension or discovery needed | Built-in: requester and sender fields track individuals |
| Reply-to discovery | Complex (CareTeam lookup) | Simple (read from CommunicationRequest.sender) |
| Custom extensions | Yes (for tracking sender org) | No |
| FHIR alignment | Workaround | Direct alignment with FHIR R4 |
| CareTeam confusion | Yes (patient care vs org messaging) | No (clear separation) |

This solution is **cleaner, more maintainable, and better aligned with FHIR semantics** while solving the same business problem.
