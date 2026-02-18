### Care Services Directory

The OZO platform participates in the Dutch care services directory ecosystem as defined by the [NL Generic Functions Implementation Guide](https://build.fhir.org/ig/nuts-foundation/nl-generic-functions-ig/). This enables organizations registered in OZO to be discoverable and interoperable within the national healthcare infrastructure.

### OZO Profiles and NL-GF

The OZO platform extends NL Generic Functions profiles for both organizations and practitioners, ensuring compliance with the Dutch care services directory and IHE mCSD (mobile Care Services Discovery) alignment.

#### OZOOrganization

The `OZOOrganization` profile extends the `nl-gf-organization` profile, which in turn extends the Nictiz `nl-core-HealthcareProvider-Organization` profile.

```
FHIR R4 Organization
  └── nl-core-HealthcareProvider-Organization (Nictiz)
        └── nl-gf-organization (NL Generic Functions / Stichting Nuts)
              └── OZOOrganization (OZO platform)
```

#### OZOPractitioner

The `OZOPractitioner` profile extends the `nl-gf-practitioner` profile, which in turn extends the Nictiz `nl-core-HealthProfessional-Practitioner` profile. This provides the same `AssignedId` identifier pattern used by organizations, linking each practitioner to their employing organization.

```
FHIR R4 Practitioner
  └── nl-core-HealthProfessional-Practitioner (Nictiz)
        └── nl-gf-practitioner (NL Generic Functions / Stichting Nuts)
              └── OZOPractitioner (OZO platform)
```

### Identifier Requirements

Both NL-GF profiles (`nl-gf-organization` and `nl-gf-practitioner`) require an `AssignedId` identifier (1..1) that links the resource to its assigning organization via URA.

#### Organization Identifiers

The NL-GF Organization profile requires organizations to provide the following identifiers:

| Identifier Slice | Cardinality | System | Description |
|-----------------|-------------|--------|-------------|
| `ura` | 0..* (conditionally required) | `http://fhir.nl/fhir/NamingSystem/ura` | URA (UZI Register Abonneenummer) - Dutch healthcare organization identifier. Required unless the organization is `partOf` another organization. |
| `agb` | 0..* | `http://fhir.nl/fhir/NamingSystem/agb-z` | AGB-Z (Algemeen GegevensBeheer) identifier |
| `AssignedId` | 1..1 | Any system | Platform-assigned identifier. Must include `system`, `value`, and an `assigner` with the URA of the assigning organization. |

The profile enforces an invariant (`ura-identifier-or-partof`): an Organization must either have a URA identifier or be `partOf` another nl-gf-organization instance.

#### AssignedId Pattern

The `AssignedId` identifies the organization within the assigning system. For OZO, the assigner is the organization itself (identified by its URA):

```json
{
  "system": "https://ozo.headease.nl/organizations",
  "value": "org-ziekenhuis-amsterdam",
  "assigner": {
    "identifier": {
      "type": {
        "coding": [{
          "system": "http://terminology.hl7.org/CodeSystem/provenance-participant-type",
          "code": "author"
        }]
      },
      "system": "http://fhir.nl/fhir/NamingSystem/ura",
      "value": "23123123123"
    }
  }
}
```

#### Practitioner Identifiers

The NL-GF Practitioner profile requires practitioners to provide:

| Identifier Slice | Cardinality | System | Description |
|-----------------|-------------|--------|-------------|
| `AssignedId` | 1..1 | Any system | Platform-assigned identifier. Must include `system`, `value`, and an `assigner` with the URA of the employing organization. |

The OZO platform uses `https://ozo.headease.nl/practitioners` as the `AssignedId` system, with the practitioner's slug as value and the employing organization's URA as assigner.

#### Practitioner AssignedId Pattern

```json
{
  "system": "https://ozo.headease.nl/practitioners",
  "value": "practitioner-manu-van-weel",
  "assigner": {
    "identifier": {
      "type": {
        "coding": [{
          "system": "http://terminology.hl7.org/CodeSystem/provenance-participant-type",
          "code": "author"
        }]
      },
      "system": "http://fhir.nl/fhir/NamingSystem/ura",
      "value": "23123123124"
    }
  }
}
```

### Organization Type

Organizations must specify their type using the Nictiz organization type code system (`http://nictiz.nl/fhir/NamingSystem/organization-type`). Common codes used in OZO:

| Code | Display |
|------|---------|
| V4 | Ziekenhuis |
| Z3 | Huisartspraktijk (zelfstandig of groepspraktijk) |
| G2 | Apotheek |

### NL-GF Profiles Referenced by OZO

OZO references the following NL-GF profiles directly in its interactions with the care services directory. These profiles are not wrapped by OZO-specific profiles, but are used as-is from the NL-GF specification:

| NL-GF Profile | FHIR Resource | Usage in OZO |
|---------------|---------------|--------------|
| `nl-gf-endpoint` | Endpoint | Technical connection details for FHIR endpoints |
| `nl-gf-healthcareservice` | HealthcareService | Services offered by organizations |
| `nl-gf-location` | Location | Physical locations of organizations |
| `nl-gf-practitionerrole` | PractitionerRole | Practitioner roles within organizations |
| `nl-gf-organizationaffiliation` | OrganizationAffiliation | Relationships between organizations |

### Directory Roles

The care services directory defines several roles for participants. OZO operates as:

#### Admin Client
The OZO system acts as an **Admin Client** to register and maintain organization entries in the directory. When a new organization joins the OZO platform, the system creates or updates the organization's entry in the care services directory, including its identifiers, type, and endpoint information.

#### Update Client
Healthcare organizations using OZO can act as **Update Clients** to maintain their own directory entries. This includes updating contact information, service offerings, and endpoint details.

#### Query Client
OZO uses the **Query Client** role to discover organizations and their capabilities within the directory. This enables features like finding organizations by type, location, or available services.

### Architecture

{::nomarkdown}
{% include care-services-directory.svg %}
{:/}

### Further Reading

- [NL Generic Functions IG](https://build.fhir.org/ig/nuts-foundation/nl-generic-functions-ig/) - Full specification
- [NL-GF Organization Profile](https://build.fhir.org/ig/nuts-foundation/nl-generic-functions-ig/StructureDefinition-nl-gf-organization.html) - Detailed profile documentation
- [NL-GF Care Services](https://build.fhir.org/ig/nuts-foundation/nl-generic-functions-ig/care-services.html) - Care services directory overview
- [IHE mCSD](https://profiles.ihe.net/ITI/mCSD/) - Mobile Care Services Discovery specification
