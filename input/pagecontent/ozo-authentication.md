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

**Access API**

1. **Initial User Interaction**:
   - The user interacts with the `client_app`.

2. **Request for Access Token**:
   - `client_app` requests an access token from `client_nuts` using the VC.
   - The request is forwarded to `ozo_nuts` with a Verifiable Presentation.

3. **Token Issuance and Communication**:
   - `ozo_nuts` provides an access token to `client_nuts`.
   - `client_nuts` conveys the access token to `client_app`.

4. **Accessing Resources**:
   - The `client_app` uses the access token to request a resource from `ozo_api`.
   - `ozo_api` requests token introspection from `ozo_nuts`.

5. **Validation and Response**:
   - `ozo_nuts` validates the access token.
   - `ozo_nuts` sends a validation response back to `ozo_api`.
   - `ozo_api` provides the requested resource to `client_app`.

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

<img alt="Image" style="float: none; width:40%; display: block" src="Trust%205.png"/>

{% include nuts_access_token_dpop.svg %}

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
 * The NutsOrganizationCredential, backed by a X509Credential
 * The NutsEmployeeCredential for each logged in practitioner.

<img alt="Image" style="float: none; width:40%; display: block" src="Trust%20Pracitioner%201.png"/>

#### Onboarding Health Care Providers

##### UZI Verifiable Credential

In order to act on behalf of a health care organization in the OZO network, a health care provider needs to identify themselves by an UZI server certificate. This certificate can be used to self-sign and issue an `X509Credential`. This credential is loaded in the organization wallet and is used to proof the UZI number ownership to the OZO network.

A tool on generating the UZI VC can be found here:

https://github.com/nuts-foundation/go-didx509-toolkit

##### NutsOrganizationCredential
The second stage of the onboarding is the `NutsOrganizationCredential`, this credential is issued by OZO in order to welcome the health care organization in the OZO network.

##### Issuance overview

{% include nuts_care_organization_overview.svg %}

###### Diagram Explanation

 **Actors and Components**

 **Actors**
- **`user`**: Represents an end-user interacting with the `client_app`.
- **`client_administrator`**: Handles administrative tasks in the client system.
- **`ozo_administrator`**: Manages administrative operations within the `ozo` system.

 **Systems and Tools**
- **`x509_toolkit`**: Used for issuing X509Credentials.
- **`client_nuts`**: Handles operations like credential creation, storage, and access token requests.
- **`client_app`**: Acts as the intermediary between the user and other systems (handles login, token generation, and API requests).
- **`ozo_nuts`**: Validates tokens and performs introspection for accessing resources.
- **`ozo_api`**: Provides protected resources for authenticated requests.

 **Databases and Boundaries**
- **`database ozo_api`**: Represents the resources/services accessed through `ozo_api`.

---

 **Processes**

 **1. Self Sign X509Credential**
- The `client_administrator` initiates the process by communicating with the `client_nuts` to create a subject/identifier.
- `client_nuts` responds with a `did:web` (Decentralized Identifier in web format).
- The `client_administrator` then requests the `x509_toolkit` to issue an X509Credential containing:
  - UZI certificate
  - Private Key
  - `did:web`
- The `x509_toolkit` returns the newly-issued X509Credential to the `client_administrator`.
- The `client_administrator` stores the X509Credential in `client_nuts`.

---

 **2. Request NutsOrganizationCredential**
- The `client_administrator` requests the issuance of a `NutsOrganizationCredential` by providing a URA (Unique Resource Allocation) number to the `ozo_administrator`.
- The `ozo_administrator` uses the `client_nuts` to create the `NutsOrganizationCredential`.
- Once created, the `NutsOrganizationCredential` is sent back to the `ozo_administrator` and then forwarded to the `client_administrator`.
- Finally, the `client_administrator` stores the `NutsOrganizationCredential` in `client_nuts`.

---

 **3. Access API**

 **User Authentication**
- A `user` interacts with the `client_app` for authentication and login.
- The `client_app` creates an `id_token` to authenticate the user.

 **Token and Credential Requests**
- The `client_app` generates a `NutsEmployeeCredential` to request an `access_token` from `client_nuts`.
- To process the request, `client_nuts` creates a Verifiable Presentation (VP) using:
  - `NutsEmployeeCredential`
- The `client_nuts` further requests an `access_token` from `ozo_nuts` using:
  - `NutsEmployeeCredential`
  - `NutsOrganizationCredential`
  - X509Credential

 **Token Handling**
- If validated, `ozo_nuts` issues an `access_token` to `client_nuts`, which is forwarded to the `client_app`.

 **API Access and Validation**
- The `client_app` uses the `access_token` to request a resource from `ozo_api`.
- The `ozo_api` calls `/introspect` on `ozo_nuts` to validate the `access_token`.
- Validation involves matching:
  - URA from `NutsOrganizationCredential`
  - X509Credential
- If validated successfully, `ozo_nuts` sends an "ok" response to `ozo_api`, allowing `ozo_api` to provide the requested resource to the `client_app`.

#### Getting API access for a logged-in user
