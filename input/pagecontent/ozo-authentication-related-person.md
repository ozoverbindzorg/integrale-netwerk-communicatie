Linking users with OZO can be done by issuing a credential (VC) to the NUTS node of the client application, issued by the OZO did:web, linked to the OZO user, and issued to the user's did:web in the client domain.

<img alt="Image" style="float: none; width:40%; display: block" src="Trust%203.png"/>

This model uses the following credential:

```yaml
Type: OZOUserCredential
Issuer: another user
Subject: did client user
```

### Explanation of NUTS architecture
#### Issuance overview

<img alt="Image" style="float: none; width:40%; display: block" src="Trust%204.png"/>

{::nomarkdown}
{% include nuts_issuance_overview.svg %}
{:/}

##### Sequence Diagram Explanation

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

{::nomarkdown}
{% include nuts_issuance_detail.svg %}
{:/}

##### Sequence Diagram Explanation

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

#### Access overview
Access to the API is provided in the context of the RelatedPerson that is active in the client application. The NUTS node of the client application holds the secrets that are required to access the OZO API, the link between the logged in user and the subject in the NUTS node needs to be protected.

The procedure of getting access to the OZO api starts with a request towards the NUTS node for an access credential. The NUTS node starts a negotiation with the NUTS node of the OZO platform. As soon as the NUTS node of the client has presented the right Verifiable Credentials in de form of signed Verifiable Presentations, the NUTS node of OZO provides an access_token. The client application uses the access_token to access the OZO API. The OZO Api introspects the access_token and uses the information in the introspection result to apply search narrowing. 

<img alt="Image" style="float: none; width:40%; display: block" src="Trust%205.png"/>

{::nomarkdown}
{% include nuts_access_token_related_person.svg %}
{:/}

##### UML Sequence Diagram Explanation

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

