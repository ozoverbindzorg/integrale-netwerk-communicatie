### Issue an internal credential
Parameters:
* base url: https://nuts-node-ozo-int.ozo.headease.nl
* subject: a subject representing the OZO system account
Note that the credential is first created as an issuer and then posted as holder. The structure is ldp_vc for now, as the jwt_vc doesn’t like to be posted.

```TypeScript
async function _fetchDid(baseUrl: string, subject: string) {
    let url = `${baseUrl}/internal/vdr/v2/subject/${subject}`
    const resp = await fetch(url, {agent: agent})
    if (resp.ok) {
        let dids = await resp.json() as Array<string>;
        for (const did of dids) {
            if (did.startsWith('did:web:')) {
                return did
            }
        }
    }
    return ''
}
```

```TypeScript
export async function selfIssue(baseUrl: string) {
    const own_subject = "other"
    const own_did = _fetchDid(baseUrl, own_subject);
    let url = `${baseUrl}/internal/vcr/v2/issuer/vc`;
    const data = {
        "type": "OzoSystemCredential",
        "issuer": own_did,
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
    url = `${baseUrl}/internal/vcr/v2/holder/${own_subject}/vc`
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
