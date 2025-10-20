The OZO AAA Proxy implements W3C Trace Context standard for distributed tracing across all API calls. This provides a standardized way to propagate trace context through the system, enabling better observability and debugging of distributed transactions.

### W3C Trace Context Headers

#### traceparent Header

The `traceparent` header is the primary trace context propagation format:

**Format:** `version-trace-id-span-id-trace-flags`

**Example:** `00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01`

**Components:**
- **version**: 2-character hex (currently `00`)
- **trace-id**: 32-character hex string representing the trace
- **span-id**: 16-character hex string representing the current operation
- **trace-flags**: 2-character hex (currently `01` for sampled)

#### tracestate Header (Optional)

The `tracestate` header carries vendor-specific trace information. While supported by the OZO AAA Proxy, it is not currently used but can be extended in the future for additional tracing vendors.

### Implementation Behavior

#### Trace Context Propagation

1. **Existing Context**: If a valid `traceparent` header is present in the request, the proxy extracts and uses the trace-id and span-id
2. **Missing Context**: If no `traceparent` header is present or it's invalid, the proxy generates a new W3C compliant trace context
3. **Downstream Propagation**: The trace context is propagated to all downstream services

#### Trace ID Generation

When generating new trace IDs, the proxy creates:
- **trace-id**: 32-character hex string (128-bit)
- **span-id**: 16-character hex string (64-bit)

Example generation:
```
trace-id: 0af7651916cd43dd8448eb211c80319c
span-id: b7ad6b7169203331
```

#### Validation

The proxy validates incoming `traceparent` headers using the regex pattern:
```
^[0-9a-f]{2}-[0-9a-f]{32}-[0-9a-f]{16}-[0-9a-f]{2}$
```

Invalid headers are ignored and new trace context is generated.

### Usage in OZO

#### API Requests

All API requests through the OZO AAA Proxy support W3C Trace Context:

```http
GET /fhir/Patient/123 HTTP/1.1
Host: api.ozo.nl
Authorization: Bearer <token>
traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01
```

#### AuditEvent Integration

The trace context is captured in AuditEvents using extensions:
- `ozo-trace-id`: Contains the 32-character trace identifier
- `ozo-span-id`: Contains the 16-character span identifier

This enables correlation between API requests and their corresponding audit trail.

#### Benefits

1. **Distributed Tracing**: Track requests across multiple services
2. **Performance Monitoring**: Identify bottlenecks in request processing
3. **Debugging**: Correlate logs and events across the system
4. **Standards Compliance**: Compatible with OpenTelemetry and other tracing systems

### Configuration

W3C Trace Context support is enabled by default in the OZO AAA Proxy. No additional configuration is required.

For integration with external tracing systems, configure your tracing backend to consume the standard W3C headers.

### Best Practices

1. **Always Include**: When building client applications, include the `traceparent` header to maintain trace continuity
2. **Preserve Context**: When making subsequent API calls, preserve and propagate the trace context
3. **Logging**: Include trace-id in application logs for correlation
4. **Monitoring**: Use trace-id to correlate metrics and events

### Example Client Implementation

#### JavaScript/TypeScript
```javascript
const traceparent = response.headers.get('traceparent') || generateTraceParent();

// Use in subsequent requests
fetch('/fhir/Patient', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'traceparent': traceparent
  }
});
```

#### Java
```java
String traceparent = response.getHeader("traceparent");
if (traceparent == null) {
    traceparent = generateTraceParent();
}

// Use in subsequent requests
request.addHeader("traceparent", traceparent);
```

### Further Reading

- [W3C Trace Context Specification](https://www.w3.org/TR/trace-context/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [W3C Trace Context Level 2](https://w3c.github.io/trace-context/)