The dropbox funcationality allows a client of the OZO FHIR API to attach a file as a URL as an attachment without having to include the file as binary to the resource. Attachments can bet added to `CommunicationRequest` resources and `Communication` resources in the `payload.contentAttachment.url` field.
### Procedure
The procedure to add an attachment to a resource is as follows:
* The client posts a file to the dropbox endpoint of the OZO API, the response will contain a 302 redirect with the URL in the Location header.
* The client creates a new `CommunicationRequest` or `Communication`  resource with the URL in the `payload.contentAttachment.url` field.
* The OZO API will fetch the resource from the FHIR repository and match the URL with the resource, if the URL is valid the OZO API will add the attachment to the message and remove the resource from the dropbox.

### Authorization
The endpoint is protected by the NUTS access_token mechanism, the client needs to include the access_token in the `Authorization` header and `DPoP` header if the token type is `DPoP`. For details please refer to the [Access the API](technical-walkthrough-access.html).

### API endpoint
The file and attributes are posted to the dropbox endpoint of the OZO API, with tha file as a form attachment. 
#### Parameters
* `careteam_id`, the logical id of the `CareTeam` resource, this parameter is part of the URL.
* `fhir_attachment[file]`, the file to upload as a multipart data.
* `fhir_attachment[resource_id]`, resource id of the resource to attach the file to.
* `access_tokem`, the access token from the NUTS node.
* `dpop_token`, the DPoP token from the NUTS node.

#### Example
```cURL
curl -X POST -H "Authorization: DPoP <access_token>" -H "DPoP: <dpop_token>" -F "fhir_attachment[resource_id]=CommunicationRequest/3123" -F "fhir_attachment[file]=@01519_1t.webp" https://connect.zorgverband.nl/fhir/clients/9632/attachments
```
### Response
The response will contain a 302 redirect, the `Location` header will contain the URL of the file.


