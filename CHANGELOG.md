# Changelog

All notable changes to the OZO FHIR Implementation Guide will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [0.7.0] - 2026-03-28

### Changed

#### Dependencies
- **BREAKING**: Removed `fhir.nl.gf` (NL Generic Functions) dependency. OZOPractitioner and OZOOrganization no longer extend NL-GF profiles — they now extend base FHIR R4 `Practitioner` and `Organization` directly. This eliminates the `AssignedId` slice, the HAPI-0574 workaround, and the dependency on an unpublished package.

#### Profiles
- **OZOPatient** - **BREAKING**: Simplified identifiers to `0..* MS` with open slicing. No named slices, no invariants. Any identifier system accepted.
- **OZORelatedPerson** - **BREAKING**: Simplified identifiers to `0..* MS` with open slicing. Removed all 5 named slices and invariant.
- **OZOPractitioner** - **BREAKING**: Rebased from `NlGfPractitioner` to `Practitioner`. Simplified identifiers to `0..* MS` with open slicing. Removed `AssignedId` slice and invariant.
- **OZOOrganization** - **BREAKING**: Rebased from `NlGfOrganization` to `Organization`. Simplified identifiers to `0..* MS` with open slicing. Removed `AssignedId` and URA slices.

#### Examples
- All 9 Practitioner examples: AssignedId system updated to `ozoverbindzorg.nl/namingsystem/professional`
- All 4 Organization examples: AssignedId system updated to `ozoverbindzorg.nl/namingsystem/organization`
- Patient and RelatedPerson examples: removed named slice references (now positional)

#### Documentation
- Updated `overview.md` identifier tables for all resource types
- Updated `interaction-network.md` identifier requirements section

## [0.6.3] - 2026-03-27

### Changed

#### Profiles
- **OZOCommunication** - Added `OZOPatient` to allowed `sender` types. Production data shows Patient resources are used as senders (4 out of 192 Communications).
- **OZOCommunicationRequest** - Added `OZOPatient` to allowed `requester` and `sender` types. Production data shows Patient resources are used as requester/sender (2 out of 33 CommunicationRequests).

#### Documentation
- **Resource Lifecycle and Deletion Policy** - New page documenting the no-DELETE policy. Resources must use status transitions instead of deletion to preserve AuditEvent referential integrity (NEN7510). Only `Patient/$expunge` is supported for AVG/GDPR right-to-erasure. Includes status mapping per resource type, security labels, and proxy enforcement guidance.

#### Examples
- **All AuditEvent examples** - Changed `entity.what` references to version-specific format (`{ResourceType}/{id}/_history/{version}`). NEN7510 requires audit events to reference the exact version of the resource accessed, not the mutable current version.

### Fixed

#### Documentation
- **AuditEvent NEN7510 page** - Added requirement that `entity.what` must use version-specific references for NEN7510 compliance. Non-versioned references become broken links when resources are deleted, undermining the legal audit trail.
- Production data conformance analysis documented in work-documents. Key findings: 94% of Communication resources missing required `status` field, and AuditEvent entity references not version-specific.

## [0.6.2] - 2026-03-27

### Changed

#### Profiles
- **OZOCommunication** - Relaxed `recipient` from `1..*` to `0..*`. Thread participants are defined on `CommunicationRequest.recipient` — individual messages do not have separate addressing. The field is kept from the parent profile for FHIR compliance but documented as unused in the OZO messaging model. Matches production data where no Communication resources have a recipient.

#### Examples
- Removed `recipient` from all Communication examples (`Reply-Manu-to-Kees`, `Reply-Kees-to-Netwerk`, `Clinic-Response-to-Pharmacy`, `Pharmacy-Followup-by-Pieter`)

#### Documentation
- Updated Communication fields table in overview.md to show `recipient 0..*` as unused
- Updated interaction flows in both messaging pages to note `recipient` is not set on Communications
- Updated team messaging query pattern to use `part-of:CommunicationRequest.recipient` instead of `Communication.recipient`

## [0.6.1] - 2026-03-27

### Added

#### CapabilityStatements
- **OZO-Server** - Base CapabilityStatement showing server identity, security requirements (Nuts + DPoP), and supported profiles.
- **OZO-System** - Full CRUD access to all resources. For server-to-server (OzoSystemCredential) access.
- **OZO-Client** - Shared CapabilityStatement for Practitioner, RelatedPerson, and Patient roles. All three roles have the same resource types and interactions — the AAA proxy scopes access differently per role via auto-applied search filters. Per-role filtering details are documented on the CapabilityStatements page.

#### Examples
- **Subscription-Communication**, **Subscription-Task-Unread**, **Subscription-CommunicationRequest** - New Subscription examples demonstrating the notify-then-pull pattern (empty `channel.payload` as required in Dutch healthcare). Covers new message detection, unread tracking, and thread lifecycle.

#### Documentation
- **CapabilityStatements** - New documentation page explaining the CapabilityStatement structure, AAA proxy access filtering per role, write validation, and Subscription support

### Changed

#### Examples
- **Clinic-Response-to-Pharmacy** - Removed `inResponseTo` reference (was pointing to deleted `Pharmacy-Initial-Message`; this is now the first reply in the thread, responding to the CommunicationRequest payload)
- **Notify-Manu-van-Weel**, **Notify-Mark-Benson**, **Notify-Kees-Groot** - Changed Task examples from `#completed` to `#requested` (initial state when created by the OZO FHIR Api). Added Title and Description.

#### Documentation
- **Messaging pages** - Replaced inline pseudo-code blocks with links to FSH example pages. Task state transitions and notification annotations remain inline as narrative.
- **Subscription guidance** - Clarified subscription behavior on both messaging pages:
  - Changed recommended subscription from `Task?id` to `Task?status=requested` to avoid subscription storms and scope via AAA proxy
  - Added "Subscription behavior" section explaining when each subscription fires and when it does **not** fire
  - Clarified that `Communication` subscription is the primary mechanism for new-message detection, not `Task`
  - Fixed misleading interaction flows that implied `Task` notifications detect new messages — `Task` is a **read/unread indicator** only
- **Notify-then-pull pattern** - Added explanation that Dutch healthcare requires empty subscription notifications; clients must pull data after notification
- **Messaging example walkthroughs** - Added detailed concrete examples to both messaging pages showing the complete flow including Tasks, AuditEvents, and subscription notifications at each step

### Removed

#### Examples
- **Pharmacy-Initial-Message** - Deleted Communication example that duplicated the CommunicationRequest payload. The CommunicationRequest carries the initial message; no separate Communication is created at thread initiation.

## [0.6.0] - 2026-03-27

### Added

#### Profiles
- **OZOOrganizationalCareTeam** - New profile for organizational/department teams used in team-to-team messaging. Represents a department or organizational unit (e.g., pharmacy team, clinic team) for shared inbox functionality. Key constraints:
  - `subject 0..0` — organizational teams have no patient
  - `managingOrganization 1..1` — required link to the owning Organization
  - `category 1..*` — required SNOMED CT coded team type
  - `name 1..1` — team display name required
  - `participant.member` restricted to `OZOPractitioner` only (no RelatedPerson in org teams)

#### Documentation
- **Team-to-Team Messaging** - New dedicated documentation page (`interaction-messaging-team.md`) with stepwise walkthrough of team-to-team messaging flows, including thread creation, replies from both teams, follow-up by different team members, and read receipts
- Added PlantUML sequence diagram for team-to-team messaging interaction

### Changed

#### Profiles
- **OZOCareTeam** - **BREAKING**: Clarified as patient care team profile only. Updated description to distinguish from `OZOOrganizationalCareTeam`. `participant.member` now also allows `OZOOrganizationalCareTeam` for nested team references (fixes existing conformance bug where `Netwerk-Jan-de-Hoop` referenced `Department-Thuiszorg` as CareTeam participant but the profile did not allow it)
- **OZOCommunication** - `recipient` now also allows `OZOOrganizationalCareTeam` in addition to existing types
- **OZOCommunicationRequest** - `recipient` now also allows `OZOOrganizationalCareTeam`. `OZOSenderCareTeam` extension tightened from `Reference(CareTeam)` to `Reference(OZOOrganizationalCareTeam)` (formalizes existing practice)

#### Examples
- **Pharmacy-A**, **Clinic-B**, **Department-Thuiszorg** - Changed from `OZOCareTeam` to `OZOOrganizationalCareTeam` profile. Removed fake `Patient/example-unassigned` subject references that were a workaround for the previous `subject 1..1` constraint

#### Documentation
- Split individual messaging page from team-to-team messaging into separate pages
- Updated overview.md with separate CareTeam (Patient) and CareTeam (Organizational) sections
- Updated interaction-network.md to reference both CareTeam profiles
- Updated HAPI installation guide with `OZOOrganizationalCareTeam` profile and canonical URL
- Updated PlantUML data model diagrams to show both CareTeam types
- Fixed documentation to correctly describe the `senderCareTeam` extension pattern (`sender` field is always an individual, extension provides CareTeam reply-to address)

## [0.5.4] - 2026-03-11

### Added

#### Documentation
- **Caching and Pagination** - New technical walkthrough page covering `Cache-Control` header requirements for FHIR requests (`no-cache` vs `no-store`), pagination with `_count` and Bundle `next` links, and the OZO proxy `Warning: 199` header for `no-store` detection

### Changed

#### Examples
- **Normalized example Instance names** - Removed abbreviated prefixes (`CT-`, `Msg-`, `Tsk-`, `AE-`) that caused ugly doubled page URLs (e.g., `CareTeam-CT-H-de-Boer.html`). The IG Publisher already prepends the resource type to page URLs, making prefixes redundant.
  - CareTeam: `CT-H-de-Boer` → `Netwerk-H-de-Boer`, `CT-Jan-de-Hoop` → `Netwerk-Jan-de-Hoop`, `CT-Department-Thuiszorg` → `Department-Thuiszorg`, `CT-Clinic-B` → `Clinic-B`, `CT-Pharmacy-A` → `Pharmacy-A`
  - Communication: `Msg-RelatedPerson-to-CareTeam` → `Reply-Kees-to-Netwerk`, `Msg-Team-Reply-1-Initial-Message` → `Pharmacy-Initial-Message`, `Msg-Team-Reply-2-Clinic-Response` → `Clinic-Response-to-Pharmacy`, `Msg-Team-Reply-3-Pharmacy-Followup` → `Pharmacy-Followup-by-Pieter`
  - Task: `Tsk-Practitioner-Manu-Example` → `Notify-Manu-van-Weel`, `Tsk-Practitioner-Mark-Example` → `Notify-Mark-Benson`, `Tsk-RelatedPerson-Example` → `Notify-Kees-Groot`
  - AuditEvent: `AE-System-Access` → `System-Read`, `AE-Practitioner-Manu-Access` → `Manu-Read-Messages`, `AE-Practitioner-Mark-Access` → `Mark-Read-Messages`, `AE-RelatedPerson-Access` → `Kees-Read-Messages`, `AE-REST-Create-Example` → `REST-Create`, `AE-REST-Search-Example` → `REST-Search`, `AE-REST-Update-Failure` → `REST-Update-Denied`

### Added

#### Examples
- **Reply-Manu-to-Kees** - New Communication example: Practitioner Manu van Weel replies to RelatedPerson Kees Groot in the Thread-Example thread. Replaces the broken `Msg-Practitioner-to-Practitioner` example (which had sender = recipient = same person and wrong payload text)

### Removed

#### Examples
- **Msg-Practitioner-to-Practitioner** - Deleted broken example where sender and recipient were both Manu van Weel and payload text was "Message from RelatedPerson to CareTeam"

### Fixed

#### Profiles
- **OZOPractitioner**, **OZOOrganization** - Fixed HAPI FHIR validation error `HAPI-0574: Slicing cannot be evaluated: Could not match discriminator ($this) for slice Practitioner.identifier:AssignedId`:
  - Added `^patternIdentifier.system` to the `AssignedId` slice on both profiles
  - The `AssignedId` slice (inherited from NL-GF parent profiles) uses a `value:$this` discriminator but lacked a top-level `patternIdentifier`, preventing HAPI from matching identifiers to the slice
  - OZOPractitioner: `https://ozo.headease.nl/practitioners`
  - OZOOrganization: `https://ozo.headease.nl/organizations`

#### Documentation
- Updated all example links in `overview.md`, `interaction-messaging.md`, `interaction-network.md`, and `auditevent-nen7510.md` to match new Instance names
- Updated cross-references in CommunicationRequest, Communication, and AuditEvent FSH files
- **HAPI Installation Guide** - Updated all version references from v0.5.1/v0.5.2 to v0.5.4

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

[0.7.0]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.6.3...v0.7.0
[0.6.3]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.6.2...v0.6.3
[0.6.2]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/compare/v0.5.4...v0.6.0
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
