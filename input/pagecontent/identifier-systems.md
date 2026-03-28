All OZO profiles use **open slicing** on `identifier` with cardinality `0..*`. The profiles do not enforce which identifier systems are used — this is a data concern managed by the OZO platform and its implementors. Any identifier system is accepted.

This page lists the identifier systems commonly used in the OZO ecosystem for reference.

### OZO platform identifiers

Base URL: `https://www.ozoverbindzorg.nl/namingsystem/`

| System | Used for | Description |
|--------|----------|-------------|
| `.../{variant}/person` | Patient, RelatedPerson | Platform user identity |
| `.../{variant}/professional` | Practitioner | Platform practitioner identity |
| `.../{variant}/organization` | Organization | Platform organization identity |
| `.../{variant}/team` | CareTeam | Platform team identity |
| `.../{variant}/network-relation` | RelatedPerson | Relationship between a person and a patient's care network |
| `.../email` | Any resource | Email address (temporary — should migrate to `telecom`) |

The `{variant}` identifies the originating system (e.g., `ozo-connect`, `ozo`, `ozo-mobile`). Multiple variants may coexist on the same resource.

### Dutch national identifiers

| System | Used for | Description |
|--------|----------|-------------|
| `http://fhir.nl/fhir/NamingSystem/bsn` | Patient | Burgerservicenummer (Dutch citizen service number) |
| `http://fhir.nl/fhir/NamingSystem/big` | Practitioner | BIG-register number (healthcare professional registration) |
| `http://fhir.nl/fhir/NamingSystem/uzi-nr-pers` | Practitioner | UZI card number (healthcare professional smart card) |
| `http://fhir.nl/fhir/NamingSystem/agb-z` | Practitioner, Organization | AGB code (healthcare provider identification) |
| `http://fhir.nl/fhir/NamingSystem/ura` | Organization | URA number (healthcare organization registration) |

### Profile approach

The OZO profiles intentionally do not constrain identifier systems. The rationale:

- **Open slicing** — any identifier system is accepted, no named slices or invariants
- **No cardinality enforcement** — `identifier 0..*` allows resources without identifiers
- **Data concern, not profile concern** — which identifiers a resource carries depends on the source system and use case, not the FHIR profile
- **Forward compatible** — new identifier systems can be introduced without profile changes
