Welcome to the OZO FHIR Implementation Guide. This guide documents the FHIR-based API for the OZO platform, which connects care professionals with informal caregivers.

### About OZO

The OZO platform is a healthcare communication platform that bridges formal healthcare networks with patients' informal social environments. The platform enables secure messaging, task management, and care coordination between healthcare professionals (practitioners) and informal caregivers (family members, friends).

### Download FHIR Package

The OZO FHIR package can be installed on FHIR servers (e.g., HAPI FHIR):

**Download:** [package.tgz](package.tgz)

#### Installation

```bash
# Using Firely Terminal
fhir install package.tgz
```

For the latest releases and version history, see the [GitHub Releases](https://github.com/ozoverbindzorg/ozo-implementation-guide/releases) page.

### Key Features

- **Decentralized Authentication**: Integration with the Nuts protocol for Dutch healthcare
- **FHIR-based Communication**: Structured messaging between practitioners and caregivers
- **NEN7510 Compliance**: Comprehensive audit logging with W3C Trace Context support
- **Dutch Healthcare Standards**: Built on NL-core profiles for national interoperability

### Quick Links

- [Overview](overview.html) - Platform architecture and data model
- [Authentication](ozo-authentication-overview.html) - Authentication flows for different user types
- [Authorization](ozo-authorization-practitioner.html) - Access control patterns
- [Artifacts](artifacts.html) - Complete list of FHIR profiles and resources
- [AuditEvent for NEN7510](auditevent-nen7510.html) - Compliance documentation

### Resources

All FHIR resources are organized around care teams that include both formal healthcare professionals and informal caregivers, enabling coordinated care under the responsibility of healthcare providers.

See the [Overview](overview.html) page for detailed information about the OZO care network and messaging data models.
