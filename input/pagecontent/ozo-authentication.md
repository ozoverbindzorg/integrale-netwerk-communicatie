### Network of trust
The OZO network of trust can be built through a Verifiable Credential (VC) architecture where OZO is the issuer of membership credentials. OZO, and specifically OZO's did:web, is considered a Trusted Party (TP) by all members who join.

<img alt="Image" style="float: none; width:40%; display: block" src="Trust%201.png"/>

The membership architecture is as follows: The OZO nuts node issues a VC to the member's NUTS node. This saves him. At the time of communication, the member's NUTS node presents a VP based on the membership VC.

<img alt="Image" style="float: none; width:40%; display: block" src="Trust%202.png"/>

This model uses the following credential:
```yaml
Type: NutsOrganizationCredential
Issuer: did OZO
Subject: did Lid
```

### Connecting Related Persons
Linking users with OZO can be done by issuing a credential (VC) to the NUTS node of the client application, issued by the OZO did:web, linked to the OZO user, and issued to the user's did:web in the client domain.

<img alt="Image" style="float: none; width:40%; display: block" src="Trust%203.png"/>

This model uses the following credential:

```yaml
Type: OZOUserCredential
Issuer: another user
Subject: did client user
```

#### Explanation of NUTS architecture
##### Issuance overview

<img alt="Image" style="float: none; width:40%; display: block" src="Trust%204.png"/>

{% include nuts_issuance_overview.svg %}

###### Sequence Diagram Explanation

This diagram illustrates the process of issuing a Verifiable Credential (VC) to a user and accessing an API using that credential. The sequence is divided into two main groups of operations: **Issue User Access VC** and **Access API**.

**Issue User Access VC**

1. **User Interaction**:
   - The user initiates interaction with the `client_app`.

2. **Request for VC Issuance**:
   - The `client_app` requests the `client_nuts` to issue a VC by the OID4VCI protocol.

3. **Engaging with Ozo Issuer**:
   - `client_nuts` sends a request to `ozo_issuer` to issue the VC as part of the OID4VCI protocol.
   - `ozo_issuer` sends an authentication request to the user.
   - The user responds by providing their credentials to `ozo_issuer`.

4. **VC Creation and Issuance**:
   - `ozo_issuer` creates the Verifiable Credential using the OID4VCI protocol.
   - The VC is issued to `client_nuts` using the OID4VCI protocol.
   - `client_nuts` stores the VC.

5. **Process Completion**:
   - The `client_nuts` informs the `client_app` that the process is complete.

This sequence diagram demonstrates how the system manages the process of VC issuance followed by secure resource access using the credential.

{% include nuts_issuance_detail.svg %}

###### Sequence Diagram Explanation

This sequence diagram illustrates the steps involved in obtaining a Verifiable Credential (VC) using the OpenID for Verifiable Credential Issuance (OID4VCI) framework. The interaction involves a user, a client application, a NUTS node client, and an OZO issuer. Here’s a breakdown of the process:

**Initial Connection and Configuration**

1. **User Connection**:
   - The "User Agent" initiates a connection with the `Client application` to start the credential issuance process.

2. **Issuance Initiation**:
   - The `Client application` instructs the `NUTS node client` to start the OID4VCI issuance process for the issuer identified as `did:web:ozo`.

3. **Request Issuer Configuration**:
   - The `NUTS node client` queries the `OZO issuer` for its OpenID credential issuer configuration file.
   - The `OZO issuer` responds with its configuration details.

4. **Discover Authorization Information**:
   - The `NUTS node client` retrieves a list of authorization servers.
   - It requests additional OpenID configuration from the `OZO issuer`.
   - The `OZO issuer` provides the necessary configuration information.

5. **Prepare for User Authorization**:
   - The `NUTS node client` identifies the authorization endpoint.
   - It generates a URL for the authorization redirect, which includes the `redirect_uri` and any required `authorization_details`.
   - This redirection URL is sent to the `Client application`, which then forwards this information to the user.

**User Authorization**

6. **Authorization Endpoint Access**:
   - The user accesses the authorization endpoint through the `OZO issuer`.
   - An authorization page is presented to the user to input their login credentials.

7. **Credential Verification**:
   - The `OZO issuer` validates the user's credentials.
   - Upon successful validation, the user is redirected to a specified redirect URI with an authorization code appended.

**Credential Issuance**

8. **Obtain an Access Token**:
   - The user follows the redirect back to the `NUTS node client`, providing the authorization code.
   - The `NUTS node client` exchanges this code for an access token from the `OZO issuer`.

9. **Request Verifiable Credential**:
   - With the access token, the `NUTS node client` requests the Verifiable Credential from the `OZO issuer`.
   - The `OZO issuer` generates and returns the VC.

10. **Finalizing the Process**:
   - The `NUTS node client` securely stores the VC.
   - A confirmation message is sent back to the user, indicating successful completion of the VC issuance process.

This structured workflow ensures a secure and reliable end-to-end system for credential issuance, leveraging the capabilities of OpenID for decentralized identity verification.

##### Access overview
Access to the API is provided in the context of the RelatedPerson that is active in the client application. The NUTS node of the client application holds the secrets that are required to access the OZO API, the link between the logged in user and the subject in the NUTS node needs to be protected.

The procedure of getting access to the OZO api starts with a request towards the NUTS node for an access credential. The NUTS node starts a negotiation with the NUTS node of the OZO platform. As soon as the NUTS node of the client has presented the right Verifiable Credentials in de form of signed Verifiable Presentations, the NUTS node of OZO provides an access_token. The client application uses the access_token to access the OZO API. The OZO Api introspects the access_token and uses the information in the introspection result to apply search narrowing. 

<img alt="Image" style="float: none; width:40%; display: block" src="Trust%205.png"/>

{% include nuts_access_token_related_person.svg %}

###### UML Sequence Diagram Explanation

**Participants**

- **Client App**: Represents the application client which initiates the requests.
- **Client NUTS**: Acts as a mediator for the client app to interact with other services.
- **NUTS OZO**: A service that handles the access token creation and validation.
- **OZO API**: An application boundary that provides endpoints for the client app to access.

**Entities**

- **Access Token**: A token used for authentication and authorization.
- **DPoP Keypair**: A keypair used to generate DPoP tokens.

**Process**

**1. Get Access Token**

1. **Client App** sends a request to **Client NUTS** to get a service access token.
2. **Client NUTS** forwards the request to **NUTS OZO** to obtain an access token for a specific subject.
3. **NUTS OZO** sends a `presentation_request` back to **Client NUTS** requiring membership and user credentials.
4. **NUTS OZO** creates an **access token** upon receiving the `presentation_response` from **Client NUTS** containing the required credentials.
5. **NUTS OZO** validates the presentation response.
6. On successful validation, **NUTS OZO** sends the generated **access token** back to **Client NUTS**.
7. **Client NUTS** creates a DPoP key.
8. **Client NUTS** returns the **access token** along with a DPoP Key ID (dpop_kid) to the **Client App**.

**2. Use Access Token**

1. **Client App** initiates a request to **Client NUTS** to get a DPoP token.
2. **Client NUTS** signs the request using the **DPoP keypair**.
3. The signed DPoP token is returned to **Client App**.
4. **Client App** makes an authenticated request to **OZO API** with the **access token** and **dpop_token**.
5. **OZO API** introspects the **access token** with **NUTS OZO**.
6. **NUTS OZO** checks the **access token**'s validity.
7. On successful validation, **NUTS OZO** indicates success to **OZO API**.
8. **OZO API** then introspects the **dpop_token** with **NUTS OZO**.
9. **NUTS OZO** verifies the **dpop_token**.
10. On successful verification, **NUTS OZO** signals success back to **OZO API**.
11. **OZO API** responds successfully to the **Client App** with the requested data.

This diagram outlines the flow for obtaining and using an access token with DPoP for secure communication between the client application and the server, illustrating interaction sequences among different participants.

### Connecting Practitioners

Practitioners from outside the OZO platform connect in a different way than RelatedPersons. The primary assumption of providing access to practitioners is that they share the same identity provider as the OZO platform does. The secondary assumption is that the application that identifies the practitioner is a health care application and is part of the OZO network as a trusted participant.  As the platforms share the same source of trust, the NutsEmployeeCredential can be leveraged to pass the user identity from the healthcare provider to the OZO platform. The credentials involved in connecting practitioners are:
 * The `X509Credential`, signed by the private key of a UZI certificate.
 * The `NutsOrganizationCredential`, matching the URA number of the X509Credential
 * The `NutsEmployeeCredential` for each logged in practitioner.

#### Explanation of NUTS architecture


<img alt="Image" style="float: none; width:40%; display: block" src="Onboard%20Organizattion%201.png"/>


##### Onboarding Health Care Providers

###### UZI Verifiable Credential

In order to act on behalf of a health care organization in the OZO network, a health care provider needs to identify themselves by an UZI server certificate. This certificate can be used to self-sign and issue an `X509Credential`. This credential is loaded in the organization wallet and is used to proof the UZI number ownership to the OZO network.

A tool on generating the UZI VC can be found here:

https://github.com/nuts-foundation/go-didx509-toolkit

###### NutsOrganizationCredential
The second stage of the onboarding is the `NutsOrganizationCredential`, this credential is issued by OZO in order to welcome the health care organization in the OZO network.

###### Onboarding overview

{% include nuts_onboarding_overview.svg %}

**Explanation of the Diagram** 

**Actors and Components**  

**Actors:**  
- **`user`:** Represents the end user initiating actions in the system.  

 **Controls:**  
- **`client_administrator`:** The primary control that interacts with different components to facilitate credential issuance and storage.  
- **`x509_toolkit`:** A control used for issuing X509 credentials.  
- **`client_nuts`:** A control used for managing credential-related actions, such as creating subjects and storing credentials.  
- **`client_app`:** Represents the user-facing entry point into the client system.  

 **Boundary:**  
- **`ozo_administrator`:** An administrative boundary involved in issuing the `NutsOrganizationCredential`.  

 **Control (Specific to OZO):**  
- **`ozo_nuts`:** A special control within the `ozo_administrator`.  

---

**Workflow 1: Self-sign X509Credential**  

 **Overview:**  
This workflow demonstrates the process of creating, signing, and storing an X509 credential.  

1. **Creating a Subject:**  
   - `client_administrator` sends a request to `client_nuts` to **create a subject**.  
   - `client_nuts` responds by sending back a `did:web` to the `client_administrator`.  

2. **Credential Issuance:**  
   - The `client_administrator` uses the `x509_toolkit` to request issuance of a **Verifiable Credential (VC)**, which includes:  
     - UZI certificate  
     - Private key  
     - `did:web`  
   - The `x509_toolkit` returns the signed `X509Credential` to the `client_administrator`.  

3. **Storing the X509Credential:**  
   - The `client_administrator` sends the signed `X509Credential` to `client_nuts` for storage.  

---

 **Workflow 2: Request NutsOrganizationCredential**  

 **Overview:**  
This workflow focuses on requesting, issuing, and storing the `NutsOrganizationCredential`.  

1. **Credential Request:**  
   - `client_administrator` requests the `ozo_administrator` to issue a `NutsOrganizationCredential`, providing a **URA number** as input.  

2. **Credential Creation:**  
   - The `ozo_administrator` forwards this request to `client_nuts` to create the `NutsOrganizationCredential`.  
   - `client_nuts` returns the created credential back to the `ozo_administrator`.  

3. **Returning the Credential:**  
   - The `ozo_administrator` sends the `NutsOrganizationCredential` to the `client_administrator`.  

4. **Storing the NutsOrganizationCredential:**  
   - The `client_administrator` stores the `NutsOrganizationCredential` in `client_nuts`.  



##### Getting API access for a logged-in Practitioner
The trust is between OZO and the client application scoped at both organization and `Practitioner` level. For each organization the following must be arranged:
* The organization must have UZI server certificate.
* The organization must have an `X509Credential` signed by the private key of the UZI server certificate.
* The organization must have an `NutsOrganizationCredential` linked to the `X509Credential` with the URA number.
* The organization must have an IdP that is used to login `Practitioner` in both the OZO platform and the client application.
* The `Practitioner` must be known in both the client application and the OZO platform.

The `X509Credential` and `NutsOrganizationCredential` reside in the wallet of the organization in the NUTS node. 

The procedure of getting access to the OZO api starts with a request towards the NUTS node for an access credential. The Practitioner must be logged in to the application with the IdP of the Organization. To request an access_token, the client application needs to initiate the token request with a self-signed `NutsEmployeeCredential` that contains the `id_token` or `SAML assertion` of the IdP. The NUTS node starts a negotiation with the NUTS node of the OZO platform. As soon as the NUTS node of the client has presented the right Verifiable Credentials in de form of signed Verifiable Presentations, the NUTS node of OZO provides an access_token. The client application uses the `access_token` to access the OZO API. The OZO Api introspects the `access_token` and uses the information in the introspection result to apply search narrowing. Furthermore, the OZO Api must check the id_token or SAML assertion with the known IdP for the domain and must check if the URA number of the `X509Credential` matches the `NutsOrganizationCredential`

<img alt="Image" style="float: none; width:40%; display: block" src="Access%20Practitioner%201.png"/>


{% include nuts_access_token_practitioner.svg %}

###### Diagram Description

The diagram illustrates a sequence of interactions between several entities to manage login, token acquisition, and secure API usage. The interactions are grouped into three key stages: **Login**, **Get access_token**, and **Use access_token**.

---

**Actors and Components**

1. **Practitioner (User)**: The end-user interacting with the system.
2. **Client App**: The application facilitating interactions between the user and backend services.
3. **Client NUTS**: A central service acting as a mediator for access management.
4. **IdP (Identity Provider)**: Performs user authentication and provides identity proofs (IdP assertions).
5. **NUTS OZO**: The organization managing credentials and tokens in the NUTS ecosystem.
6. **OZO API**: Backend API of the service being accessed.
7. **Entities Created**:
   - **access_token**: A secure token used for authentication of API requests.
   - **DPoP keypair**: Used for securing access_token with proof-of-possession.

---

**Process Breakdown**

**1. Login**
- The **Practitioner (User)** interacts with the **Client App** to log in.
- The **Client App** requests authentication from the **IdP** (Identity Provider).
- The **IdP** authenticates the user and provides an **IdP assertion** (identity proof) to the **Client App**.

---

**2. Get access_token**
- The **Client App** creates a **NutsEmployeeCredential** using the received IdP assertion.
- **Client App** requests an **access_token** from **Client NUTS**, forwarding the necessary credentials.
- **Client NUTS** contacts the **NUTS OZO** system to request an access token for the user. It sends a set of credentials for validation:
  - **X509Credential**
  - **NutsOrganizationCredential**
  - **NutsEmployeeCredential**
- **NUTS OZO** evaluates the request, validates the credentials, and creates an **access_token**.
- A **DPoP keypair** is additionally generated for the token.
- The **access_token** and the associated `dpop_kid` (key ID) are returned to the **Client App** via **Client NUTS**.

---

**3. Use access_token**

**Get DPoP token**
- The **Client App** requests a **DPoP token** from **Client NUTS**.
- **Client NUTS** signs the request using the previously generated **DPoP keypair** and provides the **DPoP token** to the **Client App**.

**Make API Request**
- The **Client App** makes an authenticated API request (`GET /api/messages`) to **OZO API**. The request includes:
  - `Authorization`: DPoP access_token
  - `DPoP`: dpop_token

**Validate access_token**
- The **OZO API** introspects the `access_token` by forwarding it to **NUTS OZO** for validation.
- **NUTS OZO** checks the token's validity and responds to the **OZO API**.
- Similarly, the **DPoP token** is verified by **NUTS OZO**, matching the DPoP proof against the access token.
- Additional checks include cross-verifying the credentials (e.g., ensuring the organization matches) and consulting the **IdP** for assertion validation if needed.
- Upon successful validation, the **OZO API** responds to the **Client App** with a `200 OK` and the requested data.

---

**Key Highlights**

1. **Authentication and Authorization Flow**:
   - Authentication is handled through the **IdP assertion**.
   - Authorization relies on both **access_token** and **DPoP token**, ensuring security and proof of possession.

2. **Credential Validation**:
   - Credentials such as **X509Credential**, **NutsOrganizationCredential**, and **NutsEmployeeCredential** are required to validate the user's identity and affiliation.

3. **Secure API Calls**:
   - Dual token validation (access and DPoP) ensures API requests are secure and originate from legitimate sources.

4. **Token Introspection and Verification**:
   - Tokens are introspected and verified by **NUTS OZO** to ensure validity throughout the process.
