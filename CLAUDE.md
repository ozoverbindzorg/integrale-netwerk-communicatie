# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **OZO FHIR Implementation Guide** - a healthcare implementation guide for the OZO platform that connects care professionals with informal caregivers. The project uses FHIR R4 (Fast Healthcare Interoperability Resources) and targets compliance with Dutch healthcare standards (NL-core profiles) and NEN7510 security requirements.

The implementation guide documents authentication, authorization, messaging, and audit logging for a healthcare communication platform that bridges formal healthcare networks with patients' informal social environments.

## Build and Development Commands

### Building the Implementation Guide

```bash
# Quick build using the pre-built Docker image (recommended)
sh build_with_image.sh

# Alternative: using Make
make build

# The build process:
# 1. Converts FSH (FHIR Shorthand) files to FHIR resources using SUSHI
# 2. Generates PlantUML diagrams from source files
# 3. Runs the HL7 IG Publisher to create the final documentation
# 4. Opens the generated site at public/index.html
```

### Working with FHIR Resources

```bash
# Convert example JSON resources back to FSH format
make update-examples

# This uses GoFSH to convert examples/ directory JSON files into FSH in input/fsh/
gofsh --useFHIRVersion=4.0.1 examples/ --out input/fsh/
```

### Generating Diagrams

```bash
# PlantUML diagrams are in input/images-source/*.plantuml
# They are automatically converted to SVG during the build process
# Manual generation (if needed):
plantuml -o ../images/ -tsvg ./input/images-source/*.plantuml
```

## Architecture and File Structure

### Key Configuration Files

- **sushi-config.yaml**: Main IG configuration - defines metadata, pages, menu structure, and dependencies
- **ig.ini**: Points to the generated ImplementationGuide resource and template
- **Dockerfile**: Defines the build environment with Java, Node.js, Ruby/Jekyll, SUSHI, and the IG Publisher

### Content Organization

**input/fsh/input/fsh/**: FHIR Shorthand definitions
- `profiles/`: FHIR profile definitions (e.g., OZOAuditEvent for NEN7510 compliance)
- `instances/`: Example resources (patients, practitioners, organizations, care teams, communications, tasks, audit events)
- `aliases.fsh`: Common aliases for code systems and profiles

**input/pagecontent/**: Markdown documentation pages (automatically included in the IG)
- Authentication flows (practitioner, related person)
- Authorization patterns
- Technical walkthroughs (mTLS setup, token validation, W3C Trace Context)
- Interaction patterns (network creation, messaging, dropbox attachments)
- Compliance documentation (NEN7510 audit events)

**input/images-source/**: PlantUML diagram sources
- Authentication/authorization flows (Nuts protocol integration)
- FHIR network and messaging interactions
- Firebase security architecture

**examples/**: JSON examples that can be converted to FSH using GoFSH

### Key FHIR Resources

The OZO platform data model centers on:
- **Patient**: Identified by BSN (Dutch citizen service number), OZO identifier
- **RelatedPerson**: Informal caregivers (family, friends) linked to patients
- **Practitioner**: Healthcare professionals
- **Organization**: Healthcare organizations (hospitals, pharmacies, general practices)
- **CareTeam**: Groups of practitioners and related persons caring for a patient
- **Communication/CommunicationRequest**: Threaded messaging system
- **Task**: Work assignments and referrals
- **AuditEvent**: NEN7510-compliant audit logging with W3C Trace Context

### Security and Authentication

The IG extensively documents:
- **Nuts protocol**: Decentralized authentication/authorization for Dutch healthcare
- **mTLS**: Mutual TLS for system-to-system authentication
- **DPoP**: Demonstrating Proof of Possession for OAuth tokens
- **W3C Trace Context**: Distributed tracing across the healthcare network
- Three access patterns: OZO system access, practitioner access, related person access

### Dependencies

- **FHIR Version**: 4.0.1
- **NL-core profiles**: nictiz.fhir.nl.r4.nl-core v0.11.0-beta.1 (Dutch localization)
- **Nuts**: Dutch healthcare authentication/authorization network

## Development Notes

### FSH (FHIR Shorthand)

This project uses FSH as the primary authoring format. FSH is compiled to FHIR JSON/XML by SUSHI during the build.

- Always edit `.fsh` files, not generated JSON
- Profile constraints use `* element cardinality MS` syntax
- ValueSets and CodeSystems are defined inline with profiles
- Extensions for W3C Trace Context are defined in the OZOAuditEvent profile

### Documentation Pages

Pages in `input/pagecontent/` are markdown files that become IG pages. The page structure and menu are defined in `sushi-config.yaml` under `pages:` and `menu:`.

### PlantUML Diagrams

Sequence and class diagrams use PlantUML syntax. The build process (via Jekyll/IG Publisher with Graphviz) converts them to SVG. Reference diagrams in markdown using relative paths to `images/`.

### Docker Build Environment

The custom Docker image includes all required tools (Java, Node.js, Ruby, Jekyll, SUSHI, IG Publisher, Graphviz). If you modify Dockerfile, rebuild the image and push to the GitLab registry referenced in the Makefile.

### Output Directories

- **output/**: Full IG Publisher output (comprehensive, includes QA reports)
- **public/**: Simplified output directory (same content, used for quick access)
- **temp/**: Temporary build artifacts
- **fsh-generated/**: SUSHI output (auto-generated FHIR resources from FSH)

Do not commit these directories to version control (they are in .gitignore).

## Common Workflows

### Adding a New Example Resource

1. Create JSON in `examples/` directory following existing patterns
2. Run `make update-examples` to generate FSH
3. Review and edit the generated FSH in `input/fsh/input/fsh/instances/`
4. Build the IG to validate

### Adding a New Documentation Page

1. Create `input/pagecontent/your-page.md`
2. Add entry to `sushi-config.yaml` under `pages:`
3. Add menu entry under `menu:` if needed
4. Build the IG

### Modifying the OZOAuditEvent Profile

The profile is in `input/fsh/input/fsh/profiles/ozo-auditevent.fsh`. It includes:
- Custom extensions for W3C Trace Context (trace-id, span-id)
- Resource origin tracking
- ValueSets for audit event types aligned with NEN7510
- Examples in `input/fsh/input/fsh/instances/auditevent-*.fsh`

### Creating Diagrams

1. Add `.plantuml` file to `input/images-source/`
2. Build the IG (diagrams are auto-generated to `input/images/`)
3. Reference in markdown: `![Description](images/your-diagram.svg)`

## Publishing

The IG is published to GitLab Pages. The `.gitlab-ci.yml` configuration automates building and deployment. The canonical URL is `http://headease.gitlab.io/ozo-refererence-impl/ozo-implementation-guide`.
