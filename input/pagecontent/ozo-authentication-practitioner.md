The primary assumption of providing access to practitioners is that they share the same identity provider as the OZO platform does. The secondary assumption is that the application that identifies the practitioner is a health care application and is part of the OZO network as a trusted participant.  As the platforms share the same source of trust, the NutsEmployeeCredential can be leveraged to pass the user identity from the healthcare provider to the OZO platform. The credentials involved in connecting practitioners are:
 * The `X509Credential`, signed by the private key of a UZI certificate.
 * The `NutsOrganizationCredential`, matching the URA number of the X509Credential
 * The `NutsEmployeeCredential` for each logged in practitioner.

### Explanation of NUTS architecture


<img alt="Image" style="float: none; width:40%; display: block" src="Onboard%20Organizattion%201.png"/>


#### Onboarding Health Care Providers

##### UZI Verifiable Credential

In order to act on behalf of a health care organization in the OZO network, a health care provider needs to identify themselves by an UZI server certificate. This certificate can be used to self-sign and issue an `X509Credential`. This credential is loaded in the organization wallet and is used to proof the UZI number ownership to the OZO network.

A tool on generating the UZI VC can be found at the [Golang did:x509 and X509Credential Toolkit](https://github.com/nuts-foundation/go-didx509-toolkit)

##### NutsOrganizationCredential
The second stage of the onboarding is the `NutsOrganizationCredential`, this credential is issued by OZO in order to welcome the health care organization in the OZO network.

##### Onboarding overview

{::nomarkdown}
{% include nuts_onboarding_overview.svg %}
{:/}

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



#### Getting API access for a logged-in Practitioner
The trust is between OZO and the client application scoped at both organization and `Practitioner` level. For each organization the following must be arranged:
* The organization must have UZI server certificate.
* The organization must have an `X509Credential` signed by the private key of the UZI server certificate.
* The organization must have an `NutsOrganizationCredential` linked to the `X509Credential` with the URA number.
* The organization must have an IdP that is used to login `Practitioner` in both the OZO platform and the client application.
* The `Practitioner` must be known in both the client application and the OZO platform.

The `X509Credential` and `NutsOrganizationCredential` reside in the wallet of the organization in the NUTS node. 

The procedure of getting access to the OZO api starts with a request towards the NUTS node for an access credential. The Practitioner must be logged in to the application with the IdP of the Organization. To request an access_token, the client application needs to initiate the token request with a self-signed `NutsEmployeeCredential` that contains the `id_token` or `SAML assertion` of the IdP. The NUTS node starts a negotiation with the NUTS node of the OZO platform. As soon as the NUTS node of the client has presented the right Verifiable Credentials in de form of signed Verifiable Presentations, the NUTS node of OZO provides an access_token. The client application uses the `access_token` to access the OZO API. The OZO Api introspects the `access_token` and uses the information in the introspection result to apply search narrowing. Furthermore, the OZO Api must check the id_token or SAML assertion with the known IdP for the domain and must check if the URA number of the `X509Credential` matches the `NutsOrganizationCredential`

<img alt="Image" style="float: none; width:40%; display: block" src="Access%20Practitioner%201.png"/>

{::nomarkdown}
{% include nuts_access_token_practitioner.svg %}
{:/}

##### Diagram Description

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

