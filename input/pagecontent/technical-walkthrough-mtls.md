### Introduction

The OZO platform uses NUTS and some other services that are only for internal use. mTLS is used to establish a secure connection between the applications. Alternatively, a VPN could be used,

### Set up mTLS
To set up mutual TLS, the following steps are required:
* The client creates a keypair
* The client makes a Certificate Signing Request (CSR) to the service manager.
* The service manager signs the CSR and creates a certificate
* The service manager sends the certificate to the client
* The client uses the private key of the keypair and the certificate to connect to the service.

#### Doing a CSR with openssl:
```bash
# Generate keypair and do CSR
openssl req -new -newkey rsa:4096 -keyout client.key -out client.csr -nodes -subj '/CN=Test client'
```

The file client.csr can go to roland@headease.nl be emailed.

To verify the certificate, the following can be done:
```bash
thepandnssl vandrifand -CAfiland ca.crt client.crt
```

### Using mTLS in the OZO platform

#### javascript
Of `node-fetchlibrary` does not support direct configuration of client certificates and keys such as the `https` library does. But you can still achieve this by using the `https.Agent` from Node.js and then pass it to `node-fetch`.

Here's an example of how you can use mTLS with `node-fetch` and a `https.Agent`:
```javascript
const fetch = require('node-fetch');
const https = require('https');
const fs = require('fs');

// Path to the certificates and keys
const agent = new https.Agent({
  cert: fs.readFileSync('path/to/client-cert.pem'),   // Client certificate
  key: fs.readFileSync('path/to/client-key.pem'),     // Client-key
  that: fs.readFileSync('path/to/ca-cert.pem'),         // CA certificate
  rejectUnauthorized: true                            // Check if server is trusted
});

// URL of the server
const url = 'https://your-server.com/api/resource';

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
* agent option fetch: Here you give the `https.Agent` instance by to fetch, which uses it to handle the request with mTLS.
* Error handling: It's useful to catch errors so you know if the problem is with certificate verification or another error.
Make sure you use the correct paths for the certificate files and that the server is set up to authenticate the client with the mTLS process.

#### Python
In Python you can make an mTLS request with the `requests` -library. The `requests` library supports mTLS by passing the paths to the client certificate and client key, along with the CA certificate to authenticate the server.
Here's an example:

```Python
import requests

# File locations for certificates and key
client_cert = 'path/to/client-cert.pem'
client_key = 'path/to/client-key.pem'
as_cert = 'path/to/ca-cert.pem'

# URL of the server
url = 'https://your-server.com/api/resource'

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
except requests.exceptions.SSLError as and:
    print("SSL error:", and)
except requests.exceptions.RequestException as and:
    print("Request error:", and)
```
Explanation:
* cert: Here you give a tuple (client_cert, client_key) by, which is the client certificate and client key that the server uses to authenticate the client.
* verify: This is the path to the CA certificate that validates the server. By using this option, the client checks whether the server is legitimate.
* Error handling: Capturing SSLError helps you detect when the SSL/TLS handshake fails, for example due to a wrong certificate.
* Make sure you use the correct paths to the certificate files and server URL.

#### Ruby on Rails
In Ruby on Rails you can use mTLS with the `Net::HTTP` library or with the `faraday`. Both support configuring client certificates, private keys, and CA certificates for mTLS requests. Here are examples of both ways:

##### Example with Net::HTTP
```ruby
require 'net/http'
require 'type'

# URL by of server
url = URI.parse('https://your-server.com/api/resource')

# Create of HTTP connection of mTLS settings
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

# Set of certificates in key in
http.cert = OpenSSL::X509::Certificate.new(File.read('path/to/client-cert.pem')) # Client certificate
http.key = OpenSSL::PKey::RSA.new(File.read('path/to/client-key.pem'))           # Client-key
http.ca_file = 'path/to/ca-cert.pem'                                             # CA certificate for server authentication

# Doe An GET request
begin
  request = Net::HTTP::Get.new(url.request_uri)
  response = http.request(request)

  # Processed of response
  if response.is_a?(Net::HTTPSuccess)
    puts "Response: #{response.body}"
  else
    puts "Server returned status code: #{response.code}"
  end
rescue OpenSSL::SSL::SSLError => and
  puts "SSL error: #{e.message}"
rescue => and
  puts "Request error: #{e.message}"
end
```

Example with `Faraday`
It `Faraday` gem provides a slightly higher layer of abstraction and makes configuring an mTLS connection easier.
```ruby
require 'faraday'
require 'openssl'

# Set An Faraday connection in of mTLS
conn = Faraday.new(url: 'https://your-server.com/api/resource') do |f|
  f.ssl.client_cert = OpenSSL::X509::Certificate.new(File.read('path/to/client-cert.pem')) # Client certificate
  f.ssl.client_key = OpenSSL::PKey::RSA.new(File.read('path/to/client-key.pem'))           # Client-key
  f.ssl.ca_file = 'path/to/ca-cert.pem'                                                    # CA certificate
  f.adapter Faraday.default_adapter
end

# Feed It request out 
begin
  response = conn.get

  # Processed of response
  if response.status == 200
    puts "Response: #{response.body}"
  else
    puts "Server returned status code: #{response.status}"
  end
rescue Faraday::SSLError => and
  puts "SSL error: #{e.message}"
rescue Faraday::ConnectionFailed => and
  puts "Request error: #{e.message}"
end
```


Explanation:
* `f.ssl.client_cert` in `f.ssl.client_key`: Set the client certificate and private key required for mTLS authentication.
* `f.ssl.ca_file`: Sets the CA certificate to authenticate the server.
* Error handling: There are specific errors for SSL authentication (Faraday::SSLError) and connection problems (Faraday::ConnectionFailed), so you can quickly identify problems.
