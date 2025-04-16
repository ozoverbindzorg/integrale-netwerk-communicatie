## 🏗️ Implementation Plan: matrix.org for OZO

---

### **1. Objective**

To integrate **matrix.org** as a secure, federated communication protocol within OZO to support care coordination, messaging, and team-based workflows—aligned with healthcare data standards and identity management.

---

### **2. Identity & Authentication Integration**

#### ✅ Identity Mapping

- **Matrix User IDs** must be linked to existing healthcare identities used by OZO:
  - **Practitioners**: Use SAML authentication via Healthcare provider's Identity Provider (IdP).
  - **RelatedPersons (e.g., family caregivers)**: Use email + password + 2FA (zorgverband.nl).
  - **Patients**: Optionally onboarded; may have local Matrix accounts based on email.

#### 🏠 Homeserver Assignment

- For **Practitioners**: Homeserver assignment is not fixed to the origin:
  - Healthcare providers choose which service provider hosts their homeserver
  - The homeserver address is published by the Generieke Functie Adressering via mCSD endpoint
  - This allows for flexibility when Healthcare providers change vendors

- For **RelatedPersons** (e.g., family caregivers) and **Patients**:  
  - Bound to the platform of origin, such as OZO

#### ✅ IdentityServer API

- Implement a **Matrix IdentityServer** that supports:
  - For **Practitioners** the identity server is bound to the Healthcare provider's IdP (`IdP + userID`), alternatively:
    - Use Generieke Functie Adressering to locate care professionals.
    - Use `UZI + method` (Dezi) as identifying mechanism.
  - For **RelatedPersons**  (e.g., family caregivers) and **Patients** the identities are provisioned by the OZO platform.
  - A single IdentityServer per homeserver (required by Matrix spec).

---

### **3. Communication Model: Rooms, Threads & Care Teams**

#### 🧠 Core Design

- **Matrix Space = Care Team**

  - Each space represents a care team associated with a specific patient.
  - Membership includes professionals and related persons involved in that patient's care.

- **Matrix Room = Conversation**

  - Each room models a FHIR `CommunicationRequest` and its subsequent `Communications`.
  - Allows structured, directed conversations with sender/recipient logic.

#### 🩺 Patient Association


- Use **room metadata** to link the patient (e.g., BSN) to the care room.
  - Use `m.space.child` and `m.space.parent` events to create a top level room and child rooms for each conversation.
- Optionally use **m.room.topic**  to link the patient (e.g., BSN) to the care room.
- If the patient is **not a room member**, represent the association as a **state event** within the room (e.g., `care.ozo.patient` event type with BSN in content).
- Note of concern: Is it ok to use the BSN, or should a pseudo-identifier should be used?

---

### **4. Messaging Model: FHIR Integration**

#### ✉️ Mapping to FHIR Resources

- Core FHIR Resources for Identity:
  - `Patient`: Maps to individuals receiving care
  - `Practitioner`: Maps to healthcare professionals
  - `Organization`: Maps to healthcare provider organizations

- Communication Resources:
  - `CommunicationRequest`: Becomes a **Matrix room with the initial message**
    - Includes sender, recipient(s), and purpose
  - `Communication`: Follows up as **room replies**
    - Includes timeline of discussions, acknowledgments, or outcomes

#### 🧭 Addressing

- All messages support addressing via Matrix mentions and roles.
- Optional: Use room tags or labels to mark urgency, topics, or domains (e.g., medication, housing, psychosocial).
- Generieke Functie Adressering provides the underlying mechanism for locating Practitioners.

---

### **5. Onboarding & Invitations**

#### 📨 User Invitation Methods

- Invite via:
  - **Homeserver ID** (e.g., `@user:homeserver.nl`)
  - **External identifier + method** (e.g., `uzi:123456789`)
- Practitioners are located by Generieke Functie Adressering via mCSD and onboarded automatically.
- RelatedPersons and patients receive **email invitations**.

---

### **6. Directory & Service Discovery: Generieke Functie Adressering and Homeserver Localization**

#### 🔎 Generieke Functie Adressering via LRZA

**Generieke Functie Adressering** (implemented as centralized mCSD Directory via LRZA) provides the framework for localization:
  - LRZA (Landelijke Register Zorgadressering) publishes one URL per Healthcare provider with their mCSD endpoint.
  - Each Healthcare provider selects one vendor to implement their mCSD endpoint.
  - The mCSD endpoint functions as an address book for each Healthcare provider.

#### 📖 Matrix User Discovery via mCSD

- **FHIR mCSD Resource Usage**:
  - Healthcare practitioners with their Matrix homeserver information are published in mCSD records.
  - Matrix homeserver addresses are stored as Endpoints of the PractitionerRole.
  - Applications use mCSD to look up practitioners and services by function or location.

#### 🔄 Practitioner Localization Process

- **Network Communication Flow for Practitioners**:
  1. Practitioner logs in using the IdP of their Healthcare provider
  2. Application searches for the practitioner in mCSD
  3. mCSD provides the homeserver and identity information
  4. Two scenarios:
     - **Option 1**: Homeserver belongs to the current vendor
       - User data is already synced or can be retrieved via standard integration (Application Service, aka AS)
     - **Option 2**: Homeserver belongs to a different vendor
       - User data must be requested during the session via client-server API

#### 📚 Data Model Extensions

- Implement mCSD/FHIR indexing for:
  - `Organization`
  - `Practitioner`
  - `PractitionerRole`
  - `HealthcareService`
  - `Endpoint` (containing Matrix homeserver details)

#### 🔁 Migration Protocol

- **When Healthcare provider changes vendors**:
  1. Healthcare provider publishes new mCSD endpoint with different vendor, or updates existing mCSD database with new homeserver addresses as Endpoints of the PractitionerRole
  2. Current vendor observes the change and for users who were active in their homeserver but are now assigned elsewhere:
     - Invites the new identity to all relevant rooms
     - Deactivates the current account using Matrix [account deactivation API](https://spec.matrix.org/v1.14/client-server-api/#post_matrixclientv3accountdeactivate)

---

### **7. Technical Stack & Deployment**

#### ⚙️ Matrix Component Overview

- **Synapse** or another Matrix homeserver as the core.
- Custom **IdentityServer** for OZO:
  - Generieke Functie Adressering and mCSD.
  - Authenticate users with a Healthcare provider IdP.
    - Authenticate users with "UZI" + "method", such as Dezi
  - Authenticate the users with their OZO account.
- Other **shared libraries**:
  - Message transformation (e.g., OZO FHIR FHIR ↔ Matrix)

---
