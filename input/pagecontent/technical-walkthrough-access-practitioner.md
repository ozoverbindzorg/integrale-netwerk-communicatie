### Create a Subject for the Organization

#### Parameters:
* `baseUrl`, from internal NUTS url: example https://nuts-node-client-int.ozo.headease.nl
* `subject`, the internal username: example myorg

```typescript
async function _createSubject(baseUrl: string, subject: string) {
    let url = `${baseUrl}/internal/vdr/v2/subject`;
    const data = {
        'subject': subject
    }
    let resp = await fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(data)
    })
    if (resp.ok) {
        return await resp.json()
    }
}
```

#### Response value

* A list of did documents. The id field of the DID document is used to request a VC to a wallet.

##### Example

```JSON
{
    "documents": [
        {
            "@context": [
                "https://www.w3.org/ns/did/v1",
                "https://w3c-ccg.github.io/lds-jws2020/contexts/lds-jws2020-v1.json"
            ],
            "assertionMethod": [
                "did:web:nuts-node.example.com:iam:5db756b2-ce83-4dcd-bf07-f0c7c2271576#0c9f6bce-d70e-449f-bfbf-4a4b4aa5a316"
            ],
            "authentication": [
                "did:web:nuts-node.example.com:iam:5db756b2-ce83-4dcd-bf07-f0c7c2271576#0c9f6bce-d70e-449f-bfbf-4a4b4aa5a316"
            ],
            "capabilityDelegation": [
                "did:web:nuts-node.example.com:iam:5db756b2-ce83-4dcd-bf07-f0c7c2271576#0c9f6bce-d70e-449f-bfbf-4a4b4aa5a316"
            ],
            "capabilityInvocation": [
                "did:web:nuts-node.example.com:iam:5db756b2-ce83-4dcd-bf07-f0c7c2271576#0c9f6bce-d70e-449f-bfbf-4a4b4aa5a316"
            ],
            "id": "did:web:nuts-node.example.com:iam:5db756b2-ce83-4dcd-bf07-f0c7c2271576",
            "verificationMethod": [
                {
                    "controller": "did:web:nuts-node.example.com:iam:5db756b2-ce83-4dcd-bf07-f0c7c2271576",
                    "id": "did:web:nuts-node.example.com:iam:5db756b2-ce83-4dcd-bf07-f0c7c2271576#0c9f6bce-d70e-449f-bfbf-4a4b4aa5a316",
                    "publicKeyJwk": {
                        "crv": "P-256",
                        "kty": "EC",
                        "x": "Yg6NXofe3qjdjssmWbTAtzce97JZu60T5DsGyKnezyc",
                        "y": "AikUTHwezwd2EOp8BqiuiCAdADplVWIW5CYl8Ls25N0"
                    },
                    "type": "JsonWebKey2020"
                }
            ]
        }
    ],
    "subject": "ozo-test"
}
```

### Get the DID from the subject
* `baseUrl`, from internal NUTS url: example https://nuts-node-client-int.ozo.headease.nl
* `subject`, the internal username: example user_3212
```typescript
async function _getDid(baseUrl: string, subject: string) {
    url = `${baseUrl}/internal/vdr/v2/subject/${subject}`
    resp = await fetch(url)
    if (resp.ok) {
        let dids = await resp.json() as Array<string>;
        for (const did of dids) {
            if (did.startsWith('did:web:')) {
                return did
            }
        }
        console.error("Failed to find a did web")
    } else {
        console.error("Failed to create did", resp.statusText)
    }
}
```

#### Response

* The list of did's associated with the account

##### Example
```JSON
[
    "did:web:nuts-node.ozo-pen.headease.nl:iam:5db756b2-ce83-4dcd-bf07-f0c7c2271576"
]
```

### Creating the X509Credential from an UZI server certificate

Make use of the [Golang did:x509 and X509Credential Toolkit](https://github.com/nuts-foundation/go-didx509-toolkit) to generate a credential.

The tool needs the following arguments:
2. The `<certificate_file>` arguments points to the issued UZI server certificate file.
3. The `<signing_key_file>` argument points to the private key associated with the UZI server certificate.
4. The `<ca_fingerprint_dn>` the DN of the certificate in the chain that should be used as ca-fingerprint. 
5. The `<credential_subject>` points to the did:web for the subject.

Example:
```bash
make install
./issuer vc certificate-chain.pem key.pem "CN=MyOrg"  did:web:nuts-node.ozo-pen.headease.nl:iam:5db756b2-ce83-4dcd-bf07-f0c7c2271576
```

Note that the [Golang did:x509 and X509Credential Toolkit](https://github.com/nuts-foundation/go-didx509-toolkit) allows for both test credentials from CIBG and self-signed testing credentials.

### Loading the X509Credential into the organizations wallet

- `baseUrl`, from internal NUTS url: example https://nuts-node-int.example.com
- `subject`, the subject of the organization.
- `credential`, the generated `X509Credential`.

```JavaScript
export async function loadCredential(baseUrl: string, subject:string, credential:string) {
  url = `${baseUrl}/internal/vcr/v2/holder/${subject}/vc`
  await fetch(url, {
      method: "POST",
      cache: "no-store",
      headers: {
          "Content-Type": "application/json",
      },
      body: JSON.stringify(credential),
  })
}

```

### Loading the NutsOrganizationCredential into the wallet

OZO should issue a `NutsOrganizationCredential` to the organization that matches the UZI number from the `X509Credential`. This credential must be loaded into the wallet of the organization.

- `baseUrl`, from internal NUTS url: example https://nuts-node-int.example.com
- `subject`, the subject of the organization.
- `credential`, the generated `X509Credential`.

```JavaScript
export async function loadCredential(baseUrl: string, subject:string, credential:string) {
  url = `${baseUrl}/internal/vcr/v2/holder/${subject}/vc`
  await fetch(url, {
      method: "POST",
      cache: "no-store",
      headers: {
          "Content-Type": "application/json",
      },
      body: JSON.stringify(credential),
  })
}

```

### Requesting an access_token

#### Parameters:

- `baseUrl`, from internal NUTS url: example https://nuts-node-client-int.ozo.headease.nl
- `subject`, the internal username: example user_3212
- `user`, the logged in user, having:
  - `identifier` the primary user identifier, in the OZO domain that is the email address.
  - `roleName` the Role of the user, for now optional.
  - `idToken` the user assertion, either a id_token or a SAML assertion.

#### Return value:

A JSON map with the `access_token` as access token and, in case of token type the field `dpop_kid` is also returned.

```typescript
export interface User {
    identifier: string;
    roleName: string;
    idToken: string;
}

export async function getAccessToken(baseUrl: string, user: User, subject: string) {
    const credential = {
        "@context": [
            "https://www.w3.org/2018/credentials/v1",
            "https://nuts.nl/credentials/v1"
        ],
        "type": ["VerifiableCredential", "NutsEmployeeCredential"],
        "credentialSubject": {
            ...user
        }
    }
    const url = `${baseUrl}/internal/auth/v2/${subject}/request-service-access-token`;
    const authorization_server = `https://nuts-node-ozo.ozo.headease.nl/oauth2/ozo`
    const data = {
        'authorization_server': `${authorization_server}`,
        'scope': 'ozo_hc',
        'token_type': 'DPoP',
        'credentials': [credential]
    }

    return await fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(data)
    })
        .then((data) => data.json() as any)
}

```

#### Response
* A JSON map with:
  * The `access_token` as access token 
  * The field `dpop_kid` if the `token_type` is DPoP, used for requesting the DPoP header
  * The `expires_in` depicting the validity of the token.
  * The `token_type`, either Bearer of DPoP.

##### Example
```JSON
{
    "access_token": "Gcmjdz....tYlWs",
    "dpop_kid": "did:web:nuts-node.ozo-pen.headease.nl:iam:b4ca905f-a8b3-450f-93ad-9e7f9fb400f7#e740976c-1b24-4cd8-8a9f-679793f93bea",
    "expires_in": 900,
    "token_type": "DPoP",
    "scope": "ozo_internal"
}
```

### Requesting a DPoP token

The DPoP header ensures that the same public/private key pair used in requesting the access_token is associated with the key pair used in using the access_token. The access_token can be used for multiple requests as long as it is valid, *a dpop header has to be requested for each individual request*. Each request needs to be signed by the private key, making sure that the access_token cannot be used by anyone other than the owner of the key pair, adding an extra layer of security. The signature method takes as input the URL and request method.

Fortunately, the NUTS node takes care of most of the complexity in getting the DPoP header, the NUTS client just needs to call the NUTS internal endpoint to fetch the DPoP header.


The following example code fetches the header:

#### Parameters:

* `baseUrl`, from internal NUTS url: example https://nuts-node-client-int.ozo.headease.nl
* `dpop_kid`: the dpop_kid from the access token response.
* `access_token`: the access_token from the token response.
* `requestMethod`: the request method in capitals, eg GET, POST or DELETE
* `requestUrl`: The URL used in the request. eg. https://example.com/fhir/Patient

```typescript
export async function getDpopHeader(baseUrl: string, dpop_kid: string, token: string, requestMethod: string, requestUrl: string) : Promise<{ dpop: string }> {
    const url = `${baseUrl}/internal/auth/v2/dpop/${encodeURIComponent(dpop_kid)}`;
    const data = {
        "htm": requestMethod,
        "htu": requestUrl,
        "token": token
    }
    return await fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
        agent: createNutsAgent(),
    })
        .then((data) => data.json() as any)
}
```

#### Return

* A JSON map with the `dpop` as dpop token.

##### Example

```JSON
{
    "dpop": "eyJhbG...JVDQ"
}
```

### Doing an API request

The API request can be done with the access_token as follows:

#### Parameters: 
* `access_token`, the access token as requested above.
* `dpop_header`, the dpop header as requested above.

```http
GET /fhir/Patient HTTP/1.1
Authorization: DPoP {access_token}
DPoP: {dpop_header}
Host: proxy.ozo.headease.nl
```
