### Network of trust
The OZO network of trust can be built through a Verifiable Credential (VC) architecture where OZO is the issuer of membership credentials. OZO, and specifically OZO's did:web, is considered a Trusted Party (TP) by all members who join.

<img alt="Image" style="float: left; width:40%" src="Trust%201.png"/>

The membership architecture is as follows: The OZO nuts node issues a VC to the member's NUTS node. This saves him. At the time of communication, the member's NUTS node presents a VP based on the membership VC.

<img alt="Image" style="float: left; width:40%" src="Trust%202.png"/>

This model uses the following credential:
```yaml
Type: OZOMembershipCredential
Issuer: did OZO
Subject: did Lid
```

### Connecting users
Linking users with OZO can be done by issuing a credential (VC) to the NUTS node of the client application, issued by the OZO did:web, linked to the OZO user, and issued to the user's did:web in the client domain.

<img alt="Image" style="float: left; width:40%" src="Trust%203.png"/>

This model uses the following credential:

```yaml
Type: OZOUserCredential
Issuer: another user
Subject: did client user
```

### Explanation of NUTS architecture
#### Issuance overview

<img alt="Image" style="float: left; width:40%" src="Trust%204.png"/>

{% include nuts_issuance_overview.svg %}

##### Sequence Diagram Explanation

This diagram illustrates the process of issuing a Verifiable Credential (VC) to a user and accessing an API using that credential. The sequence is divided into two main groups of operations: **Issue User Access VC** and **Access API**.

###### Issue User Access VC

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

###### Access API

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

##### Sequence Diagram Explanation

This sequence diagram illustrates the steps involved in obtaining a Verifiable Credential (VC) using the OpenID for Verifiable Credential Issuance (OID4VCI) framework. The interaction involves a user, a client application, a NUTS node client, and an OZO issuer. Here’s a breakdown of the process:

###### Initial Connection and Configuration

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

###### User Authorization

6. **Authorization Endpoint Access**:
   - The user accesses the authorization endpoint through the `OZO issuer`.
   - An authorization page is presented to the user to input their login credentials.

7. **Credential Verification**:
   - The `OZO issuer` validates the user's credentials.
   - Upon successful validation, the user is redirected to a specified redirect URI with an authorization code appended.

###### Credential Issuance

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

<img alt="Image" style="float: left; width:40%" src="Trust%205.png"/>

{% include nuts_access_token.svg %}

##### Diagram Explanation

This sequence diagram outlines the interactions required for a client application to obtain an access token and use it to access a specific API, showcasing the collaborative communication between various components. The main participants in this process include the Client App, Client NUTS, NUTS OZO, and OZO API. Here is a detailed explanation of each step:

###### Access Token Request

1. **Initial Request by Client App**:
   - The `Client App` sends a request to `Client NUTS` for an access token relating to the identity `did:web:user4332`.

2. **Forwarding the Request**:
   - `Client NUTS` forwards the request to `NUTS OZO` to obtain the required access token for `did:web:user4332`.

3. **Presentation Request**:
   - `NUTS OZO` sends a `presentation_request` to `Client NUTS`, asking for credentials (`OZOMembershipCredential` and `OZOUserCredential`) to be presented.

4. **Delivering Presentation Response**:
   - `Client NUTS` generates and sends a `presentation_response` back to `NUTS OZO`, containing the requested credentials.

###### Access Token Processing

5. **Validation**:
   - `NUTS OZO` performs the validation of the provided credentials to ensure authenticity and authorize the token issuance.

6. **Issuing Access Token**:
   - Upon successful validation, `NUTS OZO` sends an access token back to `Client NUTS`.
   - `Client NUTS` then relays this access token to the `Client App`.

###### Accessing the API

7. **API Request**:
   - The `Client App` uses the access token to make a secured API call to `OZO API`, specifically requesting data from `/api/messages`.

8. **Token Introspection**:
   - `OZO API` seeks to verify the access token's validity through a token introspection request to `NUTS OZO`.

9. **Verification Success**:
   - `NUTS OZO` confirms the validity of the access token and sends an "ok" response to `OZO API`.

10. **Successful API Response**:
   - The `OZO API` successfully processes the API request and returns a `200 OK` response, along with the requested data, to the `Client App`.

This sequence effectively demonstrates a workflow for secure token-based authentication in accessing protected resources via API.
