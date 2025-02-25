### Create a Subject
#### Parameters:
* `baseUrl`, from internal NUTS url: example https://nuts-node-int.example.com
- `subject`, the subject representing the OZO system, for example `ozo-connect`.

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
* `baseUrl`, from internal NUTS url: example https://nuts-node-int.example.com
*`subject`, the subject representing the OZO system, for example `ozo-connect`.

```typescript
async function _fetchDid(baseUrl: string, subject: string) {
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
        console.error("Failed to get did", resp.statusText)
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

### Self issue a `OzoSystemCredential` and load it into the wallet
* `baseUrl`, from internal NUTS url: example https://nuts-node-int.example.com
- `subject`, the subject representing the OZO system, for example `ozo-connect`
- Note that the issuer in this case is the subject `ozo`.

```TypeScript
export async function selfIssue(baseUrl: string, subject: string) {
    const own_did = _fetchDid(baseUrl, subject);
    const issuer_did = _getOrCreateDid(baseUrl, "ozo");
    let url = `${baseUrl}/internal/vcr/v2/issuer/vc`;
    const data = {
        "type": "OzoSystemCredential",
        "issuer": issuer_did,
        "credentialSubject": {
            "id": own_did
        },
        "expirationDate": "2025-01-01T00:00:00Z",
        "format": "ldp_vc"
    }
    const credential = await fetch(url, {
        method: "POST",
        cache: "no-store",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
    }).then((data) => data.json())
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

/**
 * Helper function to create the subject if missing.
 * @param subject
 * @param internalBaseUrl
 */
async function _getOrCreateDid(subject: string, internalBaseUrl: string) {
    let did: string = ''
    did = await _fetchDid(subject, internalBaseUrl, agent)
    if (did === '') {
        await _createSubject(internalBaseUrl, subject);
        did = await _fetchDid(subject, internalBaseUrl)
    }
    return did
}

```

### Requesting an `access_token`

#### Parameters:

- `baseUrl`, from internal NUTS url: example https://nuts-node-int.example.com
- `subject`, the subject representing the OZO system, for example `ozo-connect`.
- `token_type`, the token type can be either Bearer or DPoP. DPoP is highly preferred and token type Bearer might become deprecated as soon as all parties have implemented DPoP.

#### Return value:

A JSON map with the `access_token` as access token and, in case of token type the field `dpop_kid` is also returned.

```typescript
export async function getAccessToken(baseUrl: string, subject:string) {
    const authorization_server = `https://nuts-node.example.com/oauth2/ozo`
    const url = `${baseUrl}/internal/auth/v2/${subject}/request-service-access-token`;
    const data = {
        "authorization_server": authorization_server,
        "scope": "ozo",
        "token_type" : 'DPoP' // "Bearer" if skipping DPoP
    }
    return await fetch(url, {
        method: "POST",
        cache: "no-store",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
    }).then((data) => data.json())
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
    "dpop_kid": "did:web:nuts-node.example.com:iam:b4ca905f-a8b3-450f-93ad-9e7f9fb400f7#e740976c-1b24-4cd8-8a9f-679793f93bea",
    "expires_in": 900,
    "token_type": "DPoP",
    "scope": "ozo_internal"
}
```

### Requesting a `DPoP` token

The DPoP header ensures that the same public/private key pair used in requesting the access_token is associated with the key pair used in using the access_token. The access_token can be used for multiple requests as long as it is valid, *a dpop header has to be requested for each individual request*. Each request needs to be signed by the private key, making sure that the access_token cannot be used by anyone other than the owner of the key pair, adding an extra layer of security. The signature method takes as input the URL and request method.

Fortunately, the NUTS node takes care of most of the complexity in getting the DPoP header, the NUTS client just needs to call the NUTS internal endpoint to fetch the DPoP header.


The following example code fetches the header:

#### Parameters:

* `baseUrl`, from internal NUTS url: example https://nuts-node-int.example.com
* `dpop_kid`: the dpop_kid from the access token response.
* `access_token`: the access_token from the token response.

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
Host: proxy.example.com
```
