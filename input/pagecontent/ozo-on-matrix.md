
## 🏗️ Detailed Implementation Plan: Matrix.io for OZO

---

### **1. Objective**

To integrate **Matrix.io** as a secure, federated communication protocol within OZO to support care coordination, messaging, and team-based workflows—aligned with healthcare data standards and identity management.

---

### **2. Identity & Authentication Integration**

#### ✅ Identity Mapping

- **Matrix User IDs** must be linked to existing healthcare identities used by OZO:
  - **Practitioners**: Use SAML authentication via Zorgaanbieder’s Identity Provider (IdP).
  - **RelatedPersons (e.g., family caregivers)**: Use email + password + 2FA (OZOverbindzorg.nl).
  - **Patients**: Optionally onboarded; may have local Matrix accounts based on email.

#### ✅ IdentityServer API

- Implement a **Matrix IdentityServer** that supports:
  - Mapping identifiers such as UZI numbers, email, or ZorgId to Matrix user IDs.
  - Using `IdP + userID` or `UZI + method` as unique identity keys.
  - A single IdentityServer per homeserver (required by Matrix spec).

---

### **3. Communication Model: Rooms, Threads & Care Teams**

#### 🧠 Core Design

- **Matrix Room = Care Team**

  - Each room represents a care team associated with a specific patient.
  - Membership includes professionals and related persons involved in that patient's care.

- **Matrix Thread = Conversation**

  - Each thread models a FHIR `CommunicationRequest` and its subsequent `Communications`.
  - Allows structured, directed conversations with sender/recipient logic.

#### 🩺 Patient Association

- Use **room metadata** to link the patient (e.g., BSN) to the care room.
- If the patient is **not a room member**, represent the association as a **state event** within the room (e.g., `care.ozo.patient` event type with BSN in content).

---

### **4. Messaging Model: FHIR Integration**

#### ✉️ Mapping to FHIR Resources

- `CommunicationRequest`

  - Becomes a **Matrix thread root message**.
  - Includes sender, recipient(s), and purpose.

- `Communication`

  - Follows up as **thread replies**.
  - Includes timeline of discussions, acknowledgments, or outcomes.

#### 🧭 Addressing

- All messages support addressing via Matrix mentions and roles.
- Optional: Use room tags or labels to mark urgency, topics, or domains (e.g., medication, housing, psychosocial).

---

### **5. Onboarding & Invitations**

#### 📨 User Invitation Methods

- Invite via:
  - **Homeserver ID** (e.g., `@user:homeserver.nl`)
  - **External identifier + method** (e.g., `uzi:123456789`)
- Practitioners are auto-invited via identity provider federation.
- RelatedPersons and patients receive **email invitations**.

---

### **6. Directory & Service Discovery**

#### 🔎 GF Adressering Integration (via LRZA)

- Use LRZA (Landelijke Register Zorgadressering) to:
  - Look up practitioners and services by function or location.
  - Retrieve endpoint URLs and service metadata.

#### 📚 Data Model Extensions

- Implement FHIR-like indexing for:

  - `Organization`
  - `Practitioner`
  - `PractitionerRole`
  - `HealthcareService`

- Homeserver will support queries for above entities.

---

### **7. Technical Stack & Deployment**

#### ⚙️ Matrix Component Overview

- **Synapse** or another Matrix homeserver as the core.
- Custom **IdentityServer** for OZO (e.g., using [mxisd](https://github.com/kamax-io/mxisd) or custom-built).
- Other **shared libraries**:
  - Message transformation (e.g., OZO FHIR FHIR ↔ Matrix)

####

---
