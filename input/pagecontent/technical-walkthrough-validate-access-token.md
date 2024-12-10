### Step 1: Parsing the request headers

The procedure for parsing the request headers is as follows:

* Get the `Authorization` header from the request.
* Parse the header value according to the following pattern: '{type} {access_token}'. Where type can either be `Bearer`
  or `DPoP`.
    * A regex for extracting the token could look like this: `^(Bearer|DPoP) (.+)$`
* If the type is `Bearer`, only the access_token should be extracted and validated.
* If the type is `DPoP`, the `DPoP` header should be extracted and validated additionally to the access_token.

### Step 2a: Validate the access_token

The access_token can be validated by sending a request to the introspection endpoint of the authorization server. The
request should include the access_token as a parameter as part of a `application/x-www-form-urlencoded` request. The
response will contain information about the token, such as its validity and the subject it represents.

#### Parameters:

* `baseUrl`, from internal NUTS url: example https://nuts-node-int.example.com
* `access_token`, the access token to validate from the request

```TypeScript
export async function introspect(base_url: string, access_token: string) {
    const url = `${base_url}/internal/auth/v2/accesstoken/introspect`
    return await fetch(url, {
        method: "POST",
        body: 'token=' + encodeURIComponent(access_token),
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        }
    }).then((data) => data.json())
}

```

#### Response:

```JSON
{
  "active": true,
  "client_id": "https://nuts-node.example.com/oauth2/roland_test",
  "cnf": {
    "jkt": "fuu....GHQ"
  },
  "exp": 1733852948,
  "iat": 1733852048,
  "iss": "https://nuts-node.example.com/oauth2/ozo",
  "scope": "ozo"
}
```

#### Validation of the response

- The `active` field should be `true`, mind that the response status will be `200` even if the token is not valid.
- The `scope` field should match the use case of the token.
- The `iss` must match the `{base_url}/oauth2/{subject}` where the `base_url` is the external URL of the NUTS node and
  the subject is the OZO system subject.
- The `client_id` should match the expected client id.
- If the response contains as value for `cnf` the field `jkt`, the value MUST be used for the DPoP header validation. If
  no DPoP header is present, an error MUST be thrown and the validation MUST fail.

### Step 2a (Conditional): Validate the DPoP header

#### Parameters:

- `dpop_header`, the DPoP header from the request.
- `thumbprint`, the thumbprint from the introspection response at the field `cnf.jkt`.
- `access_token`, the access_token from the Authorization header.
- `http_url`, the url from the request.
- `http_method`, the HTTP method from the request, such as `GET` or `POST`.

```TypeScript

```JSON
{
  "dpop_proof": "<dpop_header>",
  "thumbprint": "<cnf.jkt>",
  "token": "<access_token>",
  "url": "<http_url>",
  "method": "<http_method>"
}
```
#### Response
```JSON
{
  "valid": true
}
```
#### Validation of the response

- The `active` field should be `true`, mind that the response status will be `200` even if the token is not valid.
