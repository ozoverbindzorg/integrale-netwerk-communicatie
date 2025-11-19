# Changelog

All notable changes to the OZO FHIR Implementation Guide will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.2] - 2025-01-19

### Added

#### Build Infrastructure
- **Minimal package generation** - Added support for building optimized FHIR packages for server deployment:
  - New `build-minimal` and `build-ig-minimal` Makefile targets
  - Minimal packages retain snapshots for faster FHIR server installation
  - Strips narratives, mappings, and documentation to reduce package size
  - Creates both full (with documentation) and minimal (server-optimized) packages

#### Scripts
- Added `scripts/convert_ig_to_package.py` - Converts ImplementationGuide to package.json format
- Added `scripts/create_index.py` - Creates .index.json for FHIR package structure
- Added `scripts/strip_narratives.py` - Strips narratives and mappings while preserving snapshots

### Changed

#### CI/CD Pipeline
- **GitHub Actions workflow** updated to build and publish both package types:
  - Builds full and minimal packages in parallel
  - Publishes both packages to GitHub Packages (minimal with `-minimal` suffix)
  - Creates GitHub releases with both package variants
  - Separate artifacts for full (`fhir-package-full`) and minimal (`fhir-package-minimal`) builds

#### Repository
- Updated `.gitignore` to exclude `/output-minimal/` and additional build artifacts

## [0.2.1] - 2025-01-14

### Changed

#### Profiles
- **Enhanced identifier system flexibility** for `OZOPatient`, `OZOPractitioner`, and `OZORelatedPerson` profiles:
  - Updated invariant expressions to use regex pattern matching (`^OZO[^/]*/ResourceType$`) instead of explicit system enumeration
  - Now supports any OZO-prefixed identifier system (e.g., `OZO/Person`, `OZO-CONNECT/Person`, `OZO-MOBILE/Person`, `OZO-WEB/Person`)
  - Enhanced slicing descriptions to clarify that additional OZO-* systems are supported through open slicing
  - Maintains validation requirement for at least one OZO identifier while allowing future system extensions

#### Examples
- Fixed identifier slice names in 9 Practitioner example instances:
  - Changed from `ozoProfessionalId` to `ozoConnectProfessionalId` for identifiers using the `OZO-CONNECT/Professional` system
  - Affected examples: A.P. Otheeker, Annemiek Jansen, Johan van den Berg, Lars Hendriks, Manu van Weel, Marijke van der Berg, Mark Benson, Pieter de Vries, Sophie de Boer

#### Technical
- Moved invariant definitions outside profile blocks to comply with FSH syntax requirements

## [0.2.0] - 2025-11-04

### Added

#### Profiles
- Added `^url`, `^name`, and `^description` metadata elements to all OZO FHIR profiles for improved canonical URL support and HAPI FHIR server compatibility:
  - `OZOAuditEvent` - `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOAuditEvent`
  - `OZOCareTeam` - `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCareTeam`
  - `OZOCommunication` - `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication`
  - `OZOCommunicationRequest` - `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunicationRequest`
  - `OZOOrganization` - `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOOrganization`
  - `OZOPatient` - `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPatient`
  - `OZOPractitioner` - `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner`
  - `OZORelatedPerson` - `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson`
  - `OZOTask` - `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask`

### Changed

#### Repository Structure
- Reorganized FSH files: moved example instances from `input/fsh/input/fsh/instances/` to `input/fsh/examples/` for improved organization and clarity
- Moved `aliases.fsh` from `input/fsh/input/fsh/` to `input/fsh/` (root level)
- Moved profile files from `input/fsh/input/fsh/profiles/` to `input/fsh/profiles/`

## [0.1.0] - 2025-10-20

### Added

#### Profiles
- Initial release of OZO FHIR profiles:
  - `OZOPatient` - Patient profile for the OZO platform with OZO Person identifier and BSN support
  - `OZOPractitioner` - Practitioner profile with OZO Professional identifier and email slicing
  - `OZORelatedPerson` - RelatedPerson profile for informal caregivers with OZO Person and NetworkRelation identifiers
  - `OZOOrganization` - Organization profile with URA and OZO Organization identifiers
  - `OZOCareTeam` - CareTeam profile representing care networks with practitioners and related persons
  - `OZOCommunication` - Communication profile for messages with thread linking via partOf
  - `OZOCommunicationRequest` - CommunicationRequest profile for message threads
  - `OZOTask` - Task profile for work assignments and referrals with thread linking via basedOn
  - `OZOAuditEvent` - AuditEvent profile for NEN7510 compliance with W3C Trace Context extensions

#### Examples
- Added comprehensive example instances for all resource types:
  - **Patients**: H. de Boer, Jan de Hoop
  - **Practitioners**: Manu van Weel, Mark Benson, A.P. Otheeker, Annemiek Jansen, Johan van den Berg, Lars Hendriks, Marijke van der Berg, Pieter de Vries, Sophie de Boer
  - **RelatedPersons**: Kees Groot, Jane Groen, Maria Groen-de Wit, Thomas Groen, Willem Bakker
  - **Organizations**: Ziekenhuis Amsterdam, Ziekenhuis Amsterdam 2, Huisarts Amsterdam, Apotheek de Pil
  - **CareTeams**: H. de Boer care team, Jan de Hoop care team, Department Thuiszorg
  - **Communications**: Practitioner-to-practitioner message, RelatedPerson-to-CareTeam message
  - **CommunicationRequests**: Thread example
  - **Tasks**: Practitioner Manu example, Practitioner Mark example, RelatedPerson example
  - **AuditEvents**: System access, Practitioner access (Manu and Mark), RelatedPerson access, REST operations (create, search, update failure)
  - **Device**: OZO AAA Proxy device for audit logging

#### Infrastructure
- Added `aliases.fsh` with common system and profile aliases
- Established FSH-first authoring workflow

[0.2.2]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/releases/tag/v0.1.0
