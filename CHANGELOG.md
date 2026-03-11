# Changelog

All notable changes to the OZO FHIR Implementation Guide will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [0.5.4] - 2026-03-11

### Fixed

#### Profiles
- **OZOPractitioner**, **OZOOrganization** - Fixed HAPI FHIR validation error `HAPI-0574: Slicing cannot be evaluated: Could not match discriminator ($this) for slice Practitioner.identifier:AssignedId`:
  - Added `^patternIdentifier.system` to the `AssignedId` slice on both profiles
  - The `AssignedId` slice (inherited from NL-GF parent profiles) uses a `value:$this` discriminator but lacked a top-level `patternIdentifier`, preventing HAPI from matching identifiers to the slice
  - OZOPractitioner: `https://ozo.headease.nl/practitioners`
  - OZOOrganization: `https://ozo.headease.nl/organizations`

## [0.5.3] - 2026-03-10

### Changed

#### Documentation
- **HAPI Installation Guide** - Major rewrite for HAPI FHIR 8.6.0 compatibility:
  - **BREAKING**: Replaced `fetchDependencies: true` approach with explicit dependency listing — transitive dependencies pull in `hl7.fhir.r4.core` and `hl7.fhir.uv.extensions.r4` which contain R5-only SearchParameters (`DeviceUsage`, `DomainResource`) that crash HAPI R4
  - Added `hl7.fhir.uv.extensions.r4` as `STORE_ONLY` entry to satisfy dependency resolution without installing problematic SearchParameters
  - Added explicit `nictiz.fhir.nl.r4.zib2020` and `nictiz.fhir.nl.r4.nl-core` entries as `STORE_AND_INSTALL`
  - Added `fhir.nl.gf` as a separate implementation guide entry (with direct `packageUrl` to CI build)
  - Set `install_transitive_ig_dependencies: false` to prevent recursive dependency installation
  - Updated prerequisites to HAPI FHIR v8.6.0+ and Java 17+
  - Updated all version references to v0.5.2 and recommended minimal package for production
  - Added troubleshooting entries for:
    - `HAPI-1684: Unknown resource name "DeviceUsage"` / `"DomainResource"` (R5-only SearchParameters)
    - `HAPI-1301: Unable to locate package fhir.nl.gf#0.3.0`
    - Database schema errors after upgrading HAPI (stale NOT NULL constraints, CHECK constraints)
  - Updated Package Dependencies table with install modes and extensions package warning
  - Updated both the Step 2 configuration and the Complete Configuration Example

## [0.5.2] - 2026-03-04

### Added

#### Documentation
- **mTLS Walkthrough** - Added "Using mTLS with a browser" section covering:
  - PKCS#12 certificate conversion from PEM files (with macOS LibreSSL workaround)
  - Browser import instructions for macOS (Safari/Chrome/Edge, Firefox), Windows (Chrome/Edge, Firefox), and Linux (Chrome, Firefox)
  - CA trust configuration for untrusted certificates
  - Command-line import via `security` tool on macOS
  - curl alternatives for direct endpoint access (including Homebrew curl and PKCS#12 usage on macOS)

### Fixed

#### Documentation
- **mTLS Walkthrough** - Removed stray backticks at the start of the file

## [0.5.1] - 2026-02-19

### Changed

#### Profiles
- **All 9 OZO profiles** - Removed individual `^version` overrides (values like "0.2.1", "1.0.0", "2.0.0") that were misleading. The IG Publisher sets `StructureDefinition.version` to the IG package version from `sushi-config.yaml`, making per-profile version overrides redundant. All profiles now consistently report the IG version.

#### Documentation
- **HAPI Installation Guide** - Major update:
  - Added **Version Discovery** section documenting how to find the active OZO IG version on a HAPI FHIR server via StructureDefinition queries and ImplementationGuide resource
  - Updated all version references from v0.1.0 to v0.5.1
  - Added `fhir.nl.gf` v0.3.0 to the package dependencies table with manual installation note
  - Added `ImplementationGuide` and `StructureDefinition` to the recommended `supported_resource_types` configuration
  - Documented known HAPI limitation: CapabilityStatement does not auto-populate `implementationGuide` field

## [0.5.0] - 2026-02-19

### Changed

#### Examples
- **All example instances** - Removed resource type prefix from FSH Instance names to fix broken example page links:
  - The IG Publisher generates pages as `{ResourceType}-{id}.html`. Previously, Instance names like `Patient-H-de-Boer` produced page URLs like `Patient-Patient-H-de-Boer.html` (doubled prefix), causing 404 errors from documentation links
  - Patient instances: removed `Patient-` prefix (e.g., `Patient-H-de-Boer` → `H-de-Boer`)
  - Practitioner instances: removed `Practitioner-` prefix (e.g., `Practitioner-Manu-van-Weel` → `Manu-van-Weel`)
  - RelatedPerson instances: removed `RelatedPerson-` prefix (e.g., `RelatedPerson-Kees-Groot` → `Kees-Groot`)
  - Organization instances: removed `Organization-` prefix (e.g., `Organization-Ziekenhuis-Amsterdam` → `Ziekenhuis-Amsterdam`)
  - CareTeam instances: replaced `CareTeam-` with `CT-` prefix (e.g., `CareTeam-H-de-Boer` → `CT-H-de-Boer`)
  - CommunicationRequest instances: removed `CommunicationRequest-` prefix (e.g., `CommunicationRequest-Thread-Example` → `Thread-Example`)
  - Communication instances: replaced `Communication-` with `Msg-` prefix (e.g., `Communication-RelatedPerson-to-CareTeam` → `Msg-RelatedPerson-to-CareTeam`)
  - Task instances: replaced `Task-` with `Tsk-` prefix (e.g., `Task-RelatedPerson-Example` → `Tsk-RelatedPerson-Example`)
  - AuditEvent instances: replaced `AuditEvent-` with `AE-` prefix (e.g., `AuditEvent-System-Access` → `AE-System-Access`)
- Removed explicit `* id` overrides from 13 instances that had numeric IDs (e.g., `* id = "1209"`) — the Instance name now serves as the id
- Converted string-based references with numeric IDs (e.g., `"Practitioner/1208"`) to FSH `Reference()` syntax (e.g., `Reference(Marijke-van-der-Berg)`) in CareTeam and RelatedPerson examples
- Updated all cross-references across 43 example files to use new Instance names

#### Documentation
- Updated example links in `overview.md`, `interaction-network.md`, `interaction-messaging.md`, and `auditevent-nen7510.md` to match new Instance names and generated page URLs

## [0.4.0] - 2026-02-18

### Changed

#### Profiles
- **OZOPractitioner** - **BREAKING**: Rebased from `Practitioner` to `NlGfPractitioner` (`nl-gf-practitioner`):
  - Now extends the NL Generic Functions Practitioner profile for mCSD care services directory compliance
  - Inherits from `nl-core-HealthProfessional-Practitioner` via `nl-gf-practitioner`
  - Inherits `AssignedId` identifier requirement (1..1) with assigner pattern linking practitioners to their employing organization
  - Removed custom identifier slices (ozoProfessionalId, ozoConnectProfessionalId, email) — incompatible with NL-GF `value:$this` slicing discriminator. OZO identifiers are still validated via `ozo-practitioner-has-professional-id` invariant and supported through open slicing
  - Profile version bumped to 2.0.0

#### Examples
- Updated all 9 Practitioner examples for NL-GF compliance:
  - Added `AssignedId` identifier with `https://ozo.headease.nl/practitioners` system, practitioner slug as value, and employing organization's URA as assigner
  - Affected: Manu van Weel, Mark Benson, A.P. Otheeker, Pieter de Vries, Johan van den Berg, Annemiek Jansen, Lars Hendriks, Marijke van der Berg, Sophie de Boer

#### Documentation
- Updated Practitioner section in Overview page with NL-GF parent profile information and AssignedId requirement
- Updated Care Services Directory page with OZOPractitioner profile hierarchy and practitioner identifier requirements

## [0.3.0] - 2026-02-17

### Added

#### Dependencies
- **NL Generic Functions IG** (`fhir.nl.gf` v0.3.0) - Added as a dependency to support care services directory compliance and IHE mCSD alignment

#### Documentation
- **Care Services Directory** - New documentation page explaining OZO's participation in the Dutch care services directory ecosystem, including directory roles (Admin Client, Update Client, Query Client), identifier requirements, and NL-GF profile references
- Added care services directory architecture diagram (`care-services-directory.plantuml`)
- Added "Care Services Directory" bullet to Key Features on the home page

### Changed

#### Profiles
- **OZOOrganization** - **BREAKING**: Rebased from `Organization` to `NlGfOrganization` (`nl-gf-organization`):
  - Now extends the NL Generic Functions Organization profile for mCSD care services directory compliance
  - Removed custom URA identifier slice (now inherited from `nl-gf-organization` via `nl-core-HealthcareProvider-Organization`)
  - Inherits `AssignedId` identifier requirement (1..1) with assigner pattern
  - Inherits `ura-identifier-or-partof` invariant: organizations must have a URA identifier or be `partOf` another organization
  - Profile version bumped to 2.0.0

#### Examples
- Updated all 4 Organization examples for NL-GF compliance:
  - **Organization-Ziekenhuis-Amsterdam** - Added `AssignedId` identifier, `type` (V4 Ziekenhuis), updated URA system to canonical URL
  - **Organization-Ziekenhuis-Amsterdam-2** - Added `AssignedId` identifier, `type` (V4 Ziekenhuis), updated URA system to canonical URL
  - **Organization-Huisarts-Amsterdam** - Added `AssignedId` identifier, `type` (Z3 Huisartspraktijk), updated URA system to canonical URL
  - **Organization-Apotheek-de-Pil** - Added `AssignedId` identifier, `type` (G2 Apotheek), updated URA system to canonical URL

#### Documentation
- Updated Organization section in Overview page with new profile information, field table, and link to Care Services Directory page

#### Build Infrastructure
- Added `install-nl-gf` Makefile target to download `fhir.nl.gf` package from CI build (package is not published on FHIR registry)
- Added `scripts/get_dependencies.py` to parse `sushi-config.yaml` dependencies for automated installation

## [0.2.5] - 2026-01-13

### Changed

#### Profiles
- **All profiles** - Converted identifier systems to valid FHIR URIs:
  - `OZO/Person` → `https://www.ozoverbindzorg.nl/namingsystem/ozo/person`
  - `OZO-CONNECT/Person` → `https://www.ozoverbindzorg.nl/namingsystem/ozo-connect/person`
  - `OZO/Professional` → `https://www.ozoverbindzorg.nl/namingsystem/ozo/professional`
  - `OZO-CONNECT/Professional` → `https://www.ozoverbindzorg.nl/namingsystem/ozo-connect/professional`
  - `OZO/Team` → `https://www.ozoverbindzorg.nl/namingsystem/ozo/team`
  - `OZO-CONNECT/Team` → `https://www.ozoverbindzorg.nl/namingsystem/ozo-connect/team`
  - `OZO/NetworkRelation` → `https://www.ozoverbindzorg.nl/namingsystem/ozo/network-relation`
  - `email` → `https://www.ozoverbindzorg.nl/namingsystem/email` (temporary - should migrate to telecom)
  - `ura` → `http://fhir.nl/fhir/NamingSystem/ura` (Nictiz standard)
  - `did_web` → `urn:ietf:rfc:3986` (value is itself a URI)
- Updated invariant expressions to match new URI patterns

#### Build Infrastructure
- Migrated Docker image from GitLab Container Registry to GitHub Container Registry (ghcr.io)
- Updated `build_with_image.sh` to use ghcr.io image
- Added GHCR push step to GitHub Actions workflow

#### Documentation
- Updated `overview.md` and `interaction-network.md` with new identifier URI patterns
- Removed outdated GitLab references from README.md and CLAUDE.md

#### Examples
- Updated all FSH and JSON example files with new identifier system URIs

## [0.2.4] - 2025-12-11

### Changed

#### Profiles
- **OZOCommunicationRequest** - Fixed CareTeam sender support using extension:
  - FHIR R4 `CommunicationRequest.sender` does not allow CareTeam references
  - Added `OZOSenderCareTeam` extension to support team-level messaging where a CareTeam needs to be the reply-to address
  - Updated team-to-team example to use the new extension pattern

#### Build Infrastructure
- Added changelog to implementation guide:
  - New `copy-changelog` Makefile target copies CHANGELOG.md to history.md during build
  - Changelog now accessible via "Changelog" menu item in the published guide

## [0.2.3] - 2025-12-04

### Changed

#### Profiles
- **OZOCommunicationRequest** - Added support for team-level messaging:
  - Added `sender` field constraint allowing `OZOPractitioner`, `OZORelatedPerson`, or `OZOCareTeam`
  - `sender` serves as the reply-to address for team-level messaging and provides team-level authorization
  - `requester` remains restricted to individuals (`OZOPractitioner` or `OZORelatedPerson`) to preserve auditability
  - Enables "shared inbox" pattern where teams (e.g., pharmacies, clinics) can send and receive messages as a unit

#### Documentation
- See [FHIR Addressing Analysis](fhir-addressing-analysis.html) for the complete rationale and message flow examples

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

[0.5.4]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.5.3...v0.5.4
[0.5.3]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.5.2...v0.5.3
[0.5.2]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.2.5...v0.3.0
[0.2.5]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.2.4...v0.2.5
[0.2.4]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/releases/tag/v0.1.0
