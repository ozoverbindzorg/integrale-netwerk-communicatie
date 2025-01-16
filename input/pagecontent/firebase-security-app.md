

{% include firebase-app-security.svg %}

### Sequence Diagram Description

This describes a sequence of interactions between various components for user authentication, secure handling of secrets, and subsequent API requests.

---

#### Main Actors and Components

- **User (usr):** The end-user interacting with the system.
- **Hello App (app):** The main application handling the user's requests.
- **Fire Base (fire):** A service used for user authentication and identification.
- **Hello API (api):** The backend API that processes requests and validates user data.
- **Nuts Node (nuts):** A service for subject creation, authentication, and token handling.
- **OZO API (ozo):** An external API used for fetching data.
- **OZO Auth (ozo_auth):** A service handling user login and credential creation.
- **App Secret (secret):** A secure entity containing application-level secrets.
- **VC (OzoUserCredential):** A virtual credential (VC) for the user, created during authentication.

---

#### Sequence of Operations

##### 1. **User Login**
- The user initiates login with the Hello App.
- The app forwards the login request to Fire Base.
- Fire Base identifies the user and exchanges credentials to generate a **JWT** token, which is sent back to the app.

##### 2. **Secret Handling**
- The app attempts to fetch the **App Secret**.
  - If the secret does not exist:
    - The app creates a new secret.
    - The secret is stored and used in subsequent steps.

##### 3. **First API Request**
- The Hello App makes a request to Hello API with the headers:
  - `X-Ozo-Key`: The App Secret.
  - `X-Fire-Key`: The JWT token.
- Hello API validates the JWT token with Fire Base and retrieves user properties.

##### 4. **Subject Creation**
- The Hello API checks if the **OZO subject property** exists in the user properties.
  - **If the property does not exist:**
    - The API requests Nuts Node to create a subject.
    - Nuts Node generates and returns a subject.
    - The API encrypts the subject:
      1. Encrypted with the **API Secret**.
      2. Encrypted again with the **App Secret**.
    - The encrypted subject is stored in Fire Base.

##### 5. **User Authentication with OIDC4CVI Flow**
- The app requests Nuts Node to initiate an **OIDC4CVI flow** for user authentication.
- Nuts Node sends a redirect URL to the app.
- The user is redirected from the app to **OZO Auth** for authentication.
- The user logs in via OZO Auth.
- OZO Auth creates credentials for the user (**VC**) and securely stores them in Nuts Node.
- The user is then redirected back to the app to complete the process.

##### 6. **Handling Existing Subject Property**
- **If the OZO subject property exists:**
  - The Hello API decrypts the subject:
    1. Decrypts using the **App Secret**.
    2. Decrypts again using the **API Secret**.
  - A note is included: If decryption fails, the API executes the **"No property present"** workflow again.

##### 7. **Access Token Retrieval**
- The Hello API interacts with Nuts Node to:
  - Retrieve the subject.
  - Request and receive an **access_token** and a **dpop_token** for the subject.
  - Sign the request.

##### 8. **API Request to OZO**
- The Hello API makes a secured request to **OZO API**, including:
  - The `Authorization` header with the **access_token**.
  - The `DPoP` header with the **dpop_token**.

---

#### Additional Notes
- The process ensures secure **storage**, **encryption**, and management of user credentials across the system.
- Integration between multiple services (Fire Base, Nuts Node, OZO API) enables seamless login and creation flows.
- Encryption and decryption steps add robust security for sensitive user data, with fallback mechanisms for error handling.
