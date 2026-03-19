### Caching and Pagination

#### Cache-Control on FHIR Requests

Clients SHOULD send `Cache-Control: no-cache` on all FHIR API requests. The OZO proxy and underlying FHIR server may cache responses, which can cause stale data — particularly problematic for real-time messaging where a newly posted Communication must be visible immediately when the thread is re-fetched.

```http
GET /fhir/Communication?part-of=CommunicationRequest/5301 HTTP/1.1
Accept: application/fhir+json
Cache-Control: no-cache
```

Without this header, clients may receive outdated Bundle results even after a new resource has been created, leading to messages appearing with a delay.

> **Warning: do NOT use `Cache-Control: no-store`**
>
> The `no-store` directive instructs the server not to store any part of the response. The FHIR server interprets this literally and will not create server-side pagination cursors (`_getpages` tokens). As a result, search results will be limited to a single page with no `next` link — even when more results exist. Use `no-cache` instead, which forces revalidation without preventing server-side state.
>
> The OZO proxy will emit a `Warning: 199` response header when it detects `no-store` on an incoming request to help diagnose this issue.

#### Pagination with `_count` and Bundle Links

FHIR search results are paginated. The server returns a Bundle with a `link` array; a `relation: "next"` entry indicates more pages are available. Clients MUST follow these links to retrieve the complete result set rather than assuming all results fit in a single page.

```json
{
  "resourceType": "Bundle",
  "type": "searchset",
  "link": [
    { "relation": "self", "url": "https://proxy.ozo.headease.nl/fhir/Patient?_count=50" },
    { "relation": "next", "url": "https://proxy.ozo.headease.nl/fhir/Patient?_count=50&_offset=50" }
  ],
  "entry": [ ... ]
}
```

To avoid missing resources, paginate until no `next` link is present. Set a reasonable upper bound on pages to prevent infinite loops in case of server misconfiguration.
