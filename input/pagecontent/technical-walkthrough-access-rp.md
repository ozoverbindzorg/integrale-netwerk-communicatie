### Requesting the DID

Parameters:
- baseUrl, from internal NUTS url: example https://nuts-node-client-int.ozo.headease.nl
- didPefix, the prefix voor het domein: example did:web:nuts-node-client.ozo.headease.nl:iam
- userId, the internal username: example kees

Return value:

The DID document. The id field of the DID document is used to request a VC to a wallet.

```typescript
async function _createDid(baseUrl: string, userId: string) {
    let url = `${baseUrl}/internal/vdr/v2/subject`;
    const data = {
        'subject': userId
    }
    let resp = await fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(data)
    })
    if (resp.ok) {
        await resp.json()
    }

    url = `${baseUrl}/internal/vdr/v2/subject/${userId}`
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

### Initiating the VC issuance to the wallet

**Parameters**:

- baseUrl, from internal NUTS url: example https://nuts-node-client-int.ozo.headease.nl
- userDidId, the id field of the user DID document.
- redirectUri, the URL to redirect to after the issuance.

**Response**:

A JSON map with the redirect_uri as a redirect URL.

```typescript
export async function requestVcToWallet(baseUrl: string, userDidId:string, redirectUri: string) {
    const url = `${baseUrl}/internal/auth/v2/${userDidId}/request-credential`;
    const issuerDid = "did:web:issuer.ozo.headease.nl";
    const type = "OzoUserCredential";
    const data = {
        issuer: issuerDid,
        redirect_uri: redirects,
        authorization_details: [
            {
                "type": "openid_credential",
                "format": "jwt_vc",
                "credential_definition": {
                    "@context": [
                        "https://www.w3.org/2018/credentials/v1",
                        "https://cibg.nl/2024/credentials/" + type.toLowerCase()
                    ],
                    "type": [
                        "VerifiableCredential",
                        type
                    ]
                }
            }
        ],
    };
    const resp = await fetch(url, {
        method: "POST",
        cache: "no-store",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
        redirect: "manual"
    });

    if (resp.status === 302) {
        const location = resp.headers.get("location");
        if (location) {
            return location;
        }
    } else if (resp.status === 200) {
        const location = (await resp.json())["redirects"];
        if (location) {
            return location;
        }
    }
    return "/error"
}
```

### Requesting an access_token

**Parameters**:

- baseUrl, from internal NUTS url: example https://nuts-node-client-int.ozo.headease.nl
- userDidId, the id field of the user DID document.
- token_type, the token type can be either Bearer or DPoP. DPoP is highly preferred and token type Bearer might become deprecated as soon as all parties have implemented DPoP.

**Return value**:

A JSON map with the access_token as access token and, in case of token type the field dpop_kid is also returned.

```typescript
export async function getAccessToken(baseUrl: string, userId:string) {
    const authorization_server = `https://nuts-node-ozo.ozo.headease.nl/oauth2/ozo`
    const url = `${baseUrl}/internal/auth/v2/${userId}/request-service-access-token`;
    const data = {
        "authorization_server": authorization_server,
        "scope": "other",
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

#### Requesting a DPoP token

The DPoP header ensures that the same public/private key pair used in requesting the access_token is associated with the key pair used in using the access_token. Each request needs to be signed by the private key, making sure that the access_token cannot be used by anyone other than the owner of the key pair, adding an extra layer of security. Fortunately, the NUTS node takes care of most of the complexity in getting the DPoP header, the NUTS client just needs to call the NUTS internal endpoint to fetch the DPoP header.

#### Getting the header

The following example code fetches the header:

- baseUrl, from internal NUTS url: example https://nuts-node-client-int.ozo.headease.nl
- kid: the dpop_kid from the access token response.
- Token: the access_token from the token response.

```typescript
export async function getDpopHeader(baseUrl: string, kid: string, token: string, requestMethod: string, requestUrl: string) : Promise<{ dpop: string }> {
    const url = `${baseUrl}/internal/auth/v2/dpop/${encodeURIComponent(kid)}`;
    const data = {
        'htm': requestMethod,
        htu: requestUrl,
        'token': token
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

### Doing an API request

The API request can be done with the access_token as follows:

```http
GET /fhir/Patient HTTP/1.1
Authorization: DPoP {access_token}
DPoP: {dpop_header}
Host: proxy.ozo.headease.nl
```
