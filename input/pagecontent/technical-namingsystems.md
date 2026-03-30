This page provides a practical guide for implementors on which naming systems to use when creating FHIR resources for the OZO platform. For the formal identifier policy, see [Identifier Systems](identifier-systems.html).

### Base URL

All OZO naming systems use the base:

```
https://www.ozoverbindzorg.nl/namingsystem/
```

### Suggested naming systems per resource

#### Patient

```
identifier[0].system = "https://www.ozoverbindzorg.nl/namingsystem/person"
identifier[0].value = "12345"                         ← platform user ID

identifier[1].system = "http://fhir.nl/fhir/NamingSystem/bsn"
identifier[1].value = "999999999"                     ← BSN (if available)
```

#### RelatedPerson

```
identifier[0].system = "https://www.ozoverbindzorg.nl/namingsystem/person"
identifier[0].value = "12345"                         ← platform user ID

identifier[1].system = "https://www.ozoverbindzorg.nl/namingsystem/network-relation"
identifier[1].value = "67890"                         ← relationship ID (unique per patient-person pair)

identifier[2].system = "https://www.ozoverbindzorg.nl/namingsystem/email"
identifier[2].value = "kees@example.nl"
```

#### Practitioner

```
identifier[0].system = "https://www.ozoverbindzorg.nl/namingsystem/professional"
identifier[0].value = "manu-van-weel"                 ← platform practitioner ID

identifier[1].system = "http://fhir.nl/fhir/NamingSystem/big"
identifier[1].value = "12345678901"                   ← BIG number (if available)

identifier[2].system = "http://fhir.nl/fhir/NamingSystem/agb-z"
identifier[2].value = "01234567"                      ← AGB code (if available)

identifier[3].system = "https://www.ozoverbindzorg.nl/namingsystem/email"
identifier[3].value = "m.vanweel@ziekenhuis.nl"
```

#### Organization

```
identifier[0].system = "https://www.ozoverbindzorg.nl/namingsystem/organization"
identifier[0].value = "ziekenhuis-amsterdam"          ← platform organization ID

identifier[1].system = "http://fhir.nl/fhir/NamingSystem/ura"
identifier[1].value = "12345678"                      ← URA number (if available)

identifier[2].system = "http://fhir.nl/fhir/NamingSystem/agb-z"
identifier[2].value = "01234567"                      ← AGB code (if available)
```

#### CareTeam

```
identifier[0].system = "https://www.ozoverbindzorg.nl/namingsystem/team"
identifier[0].value = "netwerk-h-de-boer"             ← platform team ID

identifier[1].system = "https://www.ozoverbindzorg.nl/namingsystem/email"
identifier[1].value = "team@example.nl"               ← team email (if applicable)
```

#### AuditEvent (source.observer)

AuditEvent uses a logical identifier for the source observer — no Device resource needs to exist:

```
source.observer.identifier.system = "https://www.ozoverbindzorg.nl/namingsystem/device"
source.observer.identifier.value = "aaa-proxy-001"
source.observer.display = "AAA Proxy Instance 001"
source.observer.type = "Device"
```

### National identifier reference

| System | Name | Issuer | Format |
|--------|------|--------|--------|
| `http://fhir.nl/fhir/NamingSystem/bsn` | BSN | Dutch government | 9 digits |
| `http://fhir.nl/fhir/NamingSystem/big` | BIG | CIBG | 11 digits |
| `http://fhir.nl/fhir/NamingSystem/uzi-nr-pers` | UZI | CIBG | UZI card number |
| `http://fhir.nl/fhir/NamingSystem/agb-z` | AGB | Vektis | 8 digits |
| `http://fhir.nl/fhir/NamingSystem/ura` | URA | CIBG | 8 digits |

### Notes

- All identifier systems are **suggestions** — the OZO profiles use open slicing and accept any system
- National identifiers (BSN, BIG, UZI, AGB, URA) should use the Nictiz-standard system URLs listed above
- The `email` system is temporary — email should migrate to the `telecom` field in a future version
- Multiple identifiers from different systems can coexist on the same resource
