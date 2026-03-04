### Changelog

| Version | Date       | Changes                                                                                                                                                          |
|---------|------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1.1     | 2026-03-04 | Migrated to Google CA Service (HSM-backed), switched from RSA-4096 to EC prime256v1, added environment-specific endpoints and configuration, fixed code examples |
| 1.0     | 2024-12-01 | Initial version                                                                                                                                                  |

### Introduction

The OZO platform uses NUTS and some other services that are only for internal use. mTLS is used to establish a secure connection between the applications. Alternatively, a VPN could be used.

The mTLS infrastructure is backed by Google CA Service (HSM-backed). Client certificates are signed by the OZO operator using this CA. Each environment (staging, production) has its own CA, so certificates are environment-specific and not interchangeable.

### Set up mTLS
To set up mutual TLS, the following steps are required:
* The client generates an EC key pair and a Certificate Signing Request (CSR)
* The client sends the CSR to the OZO operator. **Never send the private key.**
* The OZO operator signs the CSR with the environment's CA and returns the signed certificate
* The client uses the private key and the signed certificate to connect to the service

#### Step 1: Generate a key pair and CSR

Use the correct CN (Common Name) for the target environment:

**Staging** (connect.zorgverband.nl):
```bash
openssl req -new -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes \
  -keyout client-key.pem \
  -out client.csr \
  -subj "/CN=connect.zorgverband.nl/O=OZOverbindzorg"
```

**Production** (zorgverband.nl):
```bash
openssl req -new -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes \
  -keyout client-key.pem \
  -out client.csr \
  -subj "/CN=zorgverband.nl/O=OZOverbindzorg"
```

#### Step 2: Send the CSR to the OZO operator

Send the `client.csr` file to the OZO operator. **Never send the private key (`client-key.pem`).** The operator signs the CSR with the CA for the target environment and returns the signed certificate (`client-cert.pem`).

#### Step 3: Test the connection

Verify that the new certificate works:

**Staging:**
```bash
curl --cert client-cert.pem --key client-key.pem \
  https://nuts-node-ozo-int.staging.ozo.headease.nl/status
```

**Production:**
```bash
curl --cert client-cert.pem --key client-key.pem \
  https://nuts-node-ozo-int.ozo.headease.nl/status
```

### Endpoints

#### Staging

| Function | URL | Authentication |
|----------|-----|----------------|
| Nuts server (internal) | `https://nuts-node-ozo-int.staging.ozo.headease.nl` | mTLS |
| Nuts authorization | `https://nuts-node-ozo.staging.ozo.headease.nl/oauth2` | Public |
| FHIR proxy | `https://proxy.staging.ozo.headease.nl` | Public |
| FHIR server (direct) | `https://fhir.staging.ozo.headease.nl` | mTLS |
| FHIR Swagger UI | `https://fhir.staging.ozo.headease.nl/fhir/swagger-ui/index.html` | mTLS |

**Configuration:**
```ruby
set :nuts_server, 'https://nuts-node-ozo-int.staging.ozo.headease.nl'
set :nuts_authorization_server, 'https://nuts-node-ozo.staging.ozo.headease.nl/oauth2'
set :fhir_server, 'https://proxy.staging.ozo.headease.nl'
```

#### Production

| Function | URL | Authentication |
|----------|-----|----------------|
| Nuts server (internal) | `https://nuts-node-ozo-int.ozo.headease.nl` | mTLS |
| Nuts authorization | `https://nuts-node-ozo.ozo.headease.nl/oauth2` | Public |
| FHIR proxy | `https://proxy.ozo.headease.nl` | Public |
| FHIR server (direct) | `https://fhir.ozo.headease.nl` | mTLS |
| FHIR Swagger UI | `https://fhir.ozo.headease.nl/fhir/swagger-ui/index.html` | mTLS |

**Configuration:**
```ruby
set :nuts_server, 'https://nuts-node-ozo-int.ozo.headease.nl'
set :nuts_authorization_server, 'https://nuts-node-ozo.ozo.headease.nl/oauth2'
set :fhir_server, 'https://proxy.ozo.headease.nl'
```

**Recommendation:** Start with staging to test the integration. Then request a separate certificate for production. Each certificate is environment-specific and not interchangeable between staging and production.

### Using mTLS in the OZO platform

#### javascript
The `node-fetch` library does not support direct configuration of client certificates and keys like the `https` library does. But you can achieve this by using `https.Agent` from Node.js and passing it to `node-fetch`.

Here's an example of how you can use mTLS with `node-fetch` and an `https.Agent`:
```javascript
const fetch = require('node-fetch');
const https = require('https');
const fs = require('fs');

// Path to the certificates and keys
const agent = new https.Agent({
  cert: fs.readFileSync('path/to/client-cert.pem'),   // Client certificate
  key: fs.readFileSync('path/to/client-key.pem'),     // Client key
  ca: fs.readFileSync('path/to/ca-cert.pem'),         // CA certificate
  rejectUnauthorized: true                            // Check if server is trusted
});

// URL of the server
const url = 'https://nuts-node-ozo-int.staging.ozo.headease.nl/status';

(async () => {
  try {
    const response = await fetch(url, {
      method: 'GET',
      agent: agent
    });

    // Processing the response
    if (response.ok) {
      const data = await response.text();
      console.log('Response:', data);
    } else {
      console.error(`Server returned status: ${response.status}`);
    }
  } catch (error) {
    console.error('Request error:', error);
  }
})();
```
Explanation:
* `https.Agent`: The agent is configured with the necessary certificates and client key for mTLS.
* `agent` option in fetch: Pass the `https.Agent` instance to fetch, which uses it to handle the request with mTLS.
* Error handling: It's useful to catch errors so you know if the problem is with certificate verification or another error.
Make sure you use the correct paths for the certificate files and that the server is set up to authenticate the client with the mTLS process.

#### Python
In Python you can make an mTLS request with the `requests` library. The `requests` library supports mTLS by passing the paths to the client certificate and client key, along with the CA certificate to authenticate the server.
Here's an example:

```python
import requests

# File locations for certificates and key
client_cert = 'path/to/client-cert.pem'
client_key = 'path/to/client-key.pem'
ca_cert = 'path/to/ca-cert.pem'

# URL of the server
url = 'https://nuts-node-ozo-int.staging.ozo.headease.nl/status'

# Send the request with mTLS
try:
    response = requests.get(
        url,
        cert=(client_cert, client_key),  # Tuple of (cert, key)
        verify=ca_cert                   # Verifies server with CA certificate
    )

    # Processing the response
    if response.status_code == 200:
        print("Response:", response.text)
    else:
        print(f"Server returned status code: {response.status_code}")
except requests.exceptions.SSLError as e:
    print("SSL error:", e)
except requests.exceptions.RequestException as e:
    print("Request error:", e)
```
Explanation:
* `cert`: A tuple `(client_cert, client_key)` containing the client certificate and key that the server uses to authenticate the client.
* `verify`: The path to the CA certificate that validates the server. The client checks whether the server is legitimate.
* Error handling: Capturing `SSLError` helps detect when the SSL/TLS handshake fails, for example due to a wrong certificate.
* Make sure you use the correct paths to the certificate files and server URL.

#### Ruby on Rails
In Ruby on Rails you can use mTLS with the `Net::HTTP` library or with `Faraday`. Both support configuring client certificates, private keys, and CA certificates for mTLS requests. Here are examples of both:

##### Example with Net::HTTP
```ruby
require 'net/http'
require 'openssl'

# URL of the server
url = URI.parse('https://nuts-node-ozo-int.staging.ozo.headease.nl/status')

# Create HTTP connection with mTLS settings
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

# Set certificates and key
http.cert = OpenSSL::X509::Certificate.new(File.read('path/to/client-cert.pem')) # Client certificate
http.key = OpenSSL::PKey::EC.new(File.read('path/to/client-key.pem'))            # Client key (EC)
http.ca_file = 'path/to/ca-cert.pem'                                             # CA certificate for server authentication

# Perform a GET request
begin
  request = Net::HTTP::Get.new(url.request_uri)
  response = http.request(request)

  if response.is_a?(Net::HTTPSuccess)
    puts "Response: #{response.body}"
  else
    puts "Server returned status code: #{response.code}"
  end
rescue OpenSSL::SSL::SSLError => e
  puts "SSL error: #{e.message}"
rescue => e
  puts "Request error: #{e.message}"
end
```

##### Example with Faraday
The `Faraday` gem provides a higher layer of abstraction and makes configuring an mTLS connection easier.
```ruby
require 'faraday'
require 'openssl'

# Set up a Faraday connection with mTLS
conn = Faraday.new(url: 'https://nuts-node-ozo-int.staging.ozo.headease.nl') do |f|
  f.ssl.client_cert = OpenSSL::X509::Certificate.new(File.read('path/to/client-cert.pem')) # Client certificate
  f.ssl.client_key = OpenSSL::PKey::EC.new(File.read('path/to/client-key.pem'))            # Client key (EC)
  f.ssl.ca_file = 'path/to/ca-cert.pem'                                                    # CA certificate
  f.adapter Faraday.default_adapter
end

# Perform the request
begin
  response = conn.get('/status')

  if response.status == 200
    puts "Response: #{response.body}"
  else
    puts "Server returned status code: #{response.status}"
  end
rescue Faraday::SSLError => e
  puts "SSL error: #{e.message}"
rescue Faraday::ConnectionFailed => e
  puts "Request error: #{e.message}"
end
```

Explanation:
* `f.ssl.client_cert` and `f.ssl.client_key`: Set the client certificate and private key required for mTLS authentication.
* `f.ssl.ca_file`: Sets the CA certificate to authenticate the server.
* Error handling: There are specific errors for SSL authentication (`Faraday::SSLError`) and connection problems (`Faraday::ConnectionFailed`), so you can quickly identify problems.

### Using mTLS with a browser

To access mTLS-protected endpoints (such as Swagger UI or FHIR API docs) from a browser, you need to import the client certificate as a PKCS#12 (.p12) file.

#### Step 1: Convert your certificate to PKCS#12

Combine the signed client certificate, the private key, and optionally the CA certificate into a single `.p12` file.

**Linux / Windows:**
```bash
openssl pkcs12 -export -out client.p12 -inkey client-key.pem -in client-cert.pem
```

**macOS:** The default macOS `openssl` (LibreSSL) produces PKCS#12 files that Keychain Access may not recognise. Use the `-legacy` flag or install OpenSSL via Homebrew:

```bash
# Option A: use the -legacy flag (works with OpenSSL 3.x installed via Homebrew)
openssl pkcs12 -export -legacy -out client.p12 -inkey client-key.pem -in client-cert.pem

# Option B: if you only have the built-in LibreSSL, -legacy is not needed
/usr/bin/openssl pkcs12 -export -out client.p12 -inkey client-key.pem -in client-cert.pem
```

You will be prompted to set an export password. Remember this password for the import step.

#### Step 2: Import into your browser

##### macOS (Safari / Chrome / Edge)

Chrome, Safari, and Edge on macOS all use the system Keychain. You only need to import the certificate once.

1. Double-click the `client.p12` file — this opens **Keychain Access**
2. Enter your macOS account password if prompted to allow the modification
3. Enter the export password you set in Step 1
4. The certificate will appear under **login > My Certificates**
5. Verify the import: in Keychain Access, select **My Certificates** in the sidebar and confirm the certificate shows a disclosure triangle with a private key attached

If the certificate shows as "untrusted", you can optionally trust the CA:
1. Also import the `ca.crt` file into Keychain Access (drag and drop or **File > Import Items**)
2. Double-click the imported CA certificate
3. Expand **Trust** and set **When using this certificate** to **Always Trust**
4. Close the dialog and enter your macOS password to confirm

Alternatively, import via the command line:
```bash
security import client.p12 -k ~/Library/Keychains/login.keychain-db -P "your-export-password" -T /usr/bin/security
```

##### macOS — Firefox

Firefox on macOS has its **own** certificate store and does not use the system Keychain:
1. Go to `about:preferences#privacy`
2. Scroll down to **Certificates** and click **View Certificates**
3. Go to the **Your Certificates** tab
4. Click **Import**, select the `client.p12` file, and enter the export password

##### Windows — Chrome / Edge

1. Go to `chrome://settings/certificates` (or **Settings > Privacy and Security > Security > Manage certificates**)
2. Click **Import**
3. Select the `client.p12` file and enter the export password
4. The certificate will appear under **Your certificates**

##### Windows — Firefox

Same as macOS Firefox: `about:preferences#privacy` > **View Certificates** > **Your Certificates** > **Import**.

##### Linux — Chrome

1. Go to `chrome://settings/certificates`
2. Go to the **Your certificates** tab
3. Click **Import**, select the `client.p12` file, and enter the export password

##### Linux — Firefox

Same as macOS Firefox: `about:preferences#privacy` > **View Certificates** > **Your Certificates** > **Import**.

#### Step 3: Browse to the mTLS-protected endpoint

Navigate to the mTLS-protected URL (e.g., `https://fhir.staging.ozo.headease.nl/swagger-ui/index.html`). The browser will prompt you to select a client certificate. Choose the certificate you just imported.

**macOS tip:** If the browser does not prompt for a certificate, try restarting the browser after importing. Safari sometimes requires a full restart to pick up newly added client certificates from the Keychain.

#### Using curl as an alternative

If browser configuration is not practical, you can use `curl` to access the endpoints directly:

```bash
curl --cert client-cert.pem --key client-key.pem https://fhir.staging.ozo.headease.nl/fhir/swagger-ui/index.html
```

**macOS note:** The built-in `/usr/bin/curl` uses Apple's Secure Transport and may not support PEM files directly. Use Homebrew's curl or specify a `.p12` file instead:

```bash
# Using Homebrew curl (recommended)
/opt/homebrew/opt/curl/bin/curl --cert client-cert.pem --key client-key.pem https://fhir.staging.ozo.headease.nl/fhir/swagger-ui/index.html

# Using built-in curl with PKCS#12
curl --cert client.p12:export-password https://fhir.staging.ozo.headease.nl/fhir/swagger-ui/index.html
```
