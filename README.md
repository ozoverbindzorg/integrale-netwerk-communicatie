# OZO FHIR Implementation Guide

FHIR Implementation Guide for the OZO platform - connecting care professionals with informal caregivers.

**Published URLs:**
- **Primary (GitHub Pages)**: `https://ozo-implementation-guide.headease.nl`
- **GitLab Pages**: `https://ozo-implementation-guide-405d2b.gitlab.io`

----

## OZO Platform

The OZO platform is a healthcare communication platform that bridges formal healthcare networks with patients' informal social environments. The platform enables secure messaging, task management, and care coordination between healthcare professionals (practitioners) and informal caregivers (family members, friends).

Key features:
- **Decentralized Authentication**: Integration with the Nuts protocol for Dutch healthcare
- **FHIR-based Communication**: Structured messaging between practitioners and caregivers
- **NEN7510 Compliance**: Comprehensive audit logging with W3C Trace Context support
- **Dutch Healthcare Standards**: Built on NL-core profiles for national interoperability

All FHIR resources are organized around care teams that include both formal healthcare professionals and informal caregivers, enabling coordinated care under the responsibility of healthcare providers.

## Build Process

This project uses the HL7 FHIR IG Publisher to generate a complete Implementation Guide from FHIR Shorthand (FSH) definitions.

### Prerequisites

#### Using Docker (Recommended)
- Docker installed on your system
- No other dependencies required

### Quick Start with Docker

The easiest way to build the project is using the pre-built Docker image.

#### Option 1: Using the build script (Recommended)

```bash
sh build_with_image.sh
```

This script will:
1. Pull the latest Docker image from GitLab registry
2. Run the build inside the container
3. Open the result in your browser

#### Option 2: Using Docker directly

```bash
# Set the image name (or use default)
IMAGE_NAME=registry.gitlab.com/headease/ozo-refererence-impl/ozo-implementation-guide/main:latest

# Pull the latest image
docker pull $IMAGE_NAME

# Create output directories
mkdir -p ./public ./output

# Run the build (mounts entire project directory)
docker run --rm -v "${PWD}:/src" $IMAGE_NAME

# View the result
open public/index.html  # macOS
# or
xdg-open public/index.html  # Linux
```

#### Option 3: Build with a locally built Docker image

First, build the image:

```bash
docker build -t ozo-ig-builder .
```

You can customize the build with version arguments:

```bash
docker build \
  --build-arg PUBLISHER_VERSION=2.0.15 \
  --build-arg SUSHI_VERSION=3.16.5 \
  -t ozo-ig-builder .
```

Then run the build:

```bash
docker run --rm -v "${PWD}:/src" ozo-ig-builder
```

### Build Output

The build process creates a complete Implementation Guide:

#### Documentation Output
- **Location**: `public/index.html`
- **Purpose**: Human-readable documentation website
- **Features**:
  - Complete HTML documentation
  - Profile definitions and examples
  - PlantUML sequence and class diagrams
  - Markdown documentation pages
  - QA validation reports

#### Additional Outputs
- `output/` - Full IG Publisher output with detailed reports (when mounted)
- `fsh-generated/` - Auto-generated FHIR resources from FSH
- `temp/` - Temporary build artifacts

### Viewing the Implementation Guide

After building, open `public/index.html` in your browser to view the complete Implementation Guide.

```bash
# macOS
open public/index.html

# Linux
xdg-open public/index.html

# Windows
start public/index.html
```

## Project Structure

```
ozo-implementation-guide/
├── input/
│   ├── fsh/
│   │   ├── profiles/          # FHIR profile definitions
│   │   │   ├── ozo-patient.fsh
│   │   │   ├── ozo-practitioner.fsh
│   │   │   ├── ozo-relatedperson.fsh
│   │   │   ├── ozo-organization.fsh
│   │   │   ├── ozo-careteam.fsh
│   │   │   ├── ozo-communication.fsh
│   │   │   ├── ozo-communicationrequest.fsh
│   │   │   ├── ozo-task.fsh
│   │   │   └── ozo-auditevent.fsh
│   │   ├── instances/         # Example resources
│   │   └── aliases.fsh        # Common aliases
│   ├── pagecontent/           # Markdown documentation pages
│   │   ├── index.md
│   │   ├── authentication-practitioner.md
│   │   ├── authentication-relatedperson.md
│   │   ├── authorization.md
│   │   ├── nen7510-auditevent.md
│   │   └── ...
│   └── images-source/         # PlantUML diagram sources
│       ├── nuts_issuance_overview.plantuml
│       ├── fhir-messaging-interaction.plantuml
│       └── ...
├── examples/                  # JSON example resources (converted to FSH)
├── public/                    # Built IG output (not in git)
├── output/                    # Full IG Publisher output (not in git)
├── fsh-generated/             # SUSHI output (not in git)
├── temp/                      # Build artifacts (not in git)
├── sushi-config.yaml          # Main IG configuration
├── ig.ini                     # IG Publisher configuration
├── Dockerfile                 # Build environment definition
├── docker-entrypoint.sh       # Docker entrypoint script
├── Makefile                   # Build commands (runs inside container)
├── build_with_image.sh        # Quick build script (runs on host)
└── CLAUDE.md                  # Development guidelines
```

## Key FHIR Resources

The OZO platform data model includes:

- **Patient**: Dutch citizens identified by BSN (citizen service number)
- **RelatedPerson**: Informal caregivers (family, friends) linked to patients
- **Practitioner**: Healthcare professionals (doctors, nurses, therapists)
- **Organization**: Healthcare organizations (hospitals, clinics, pharmacies)
- **CareTeam**: Groups of practitioners and related persons caring for a patient
- **Communication/CommunicationRequest**: Threaded messaging system between care team members
- **Task**: Work assignments, referrals, and care activities
- **AuditEvent**: NEN7510-compliant audit logging with W3C Trace Context extensions

## Development

### Working Inside the Docker Container

The Makefile is designed to run inside the Docker container. To get an interactive shell:

```bash
docker run -it --entrypoint /bin/bash \
  -v "${PWD}:/src" \
  registry.gitlab.com/headease/ozo-refererence-impl/ozo-implementation-guide/main:latest
```

Inside the container, you can use:

```bash
# Build everything
make build

# Or individual steps
make install-dependencies
make build-ig

# Validate FSH files
make validate

# Generate diagrams only
make diagrams

# Convert JSON examples to FSH
make update-examples

# Show version
make version

# Clean build artifacts
make clean

# Show all available targets
make help
```

### Working with FHIR Shorthand (FSH)

This project uses FSH as the primary authoring format. Always edit `.fsh` files rather than generated JSON.

To convert JSON examples to FSH (requires GoFSH installed on host or inside container):

```bash
# Inside container
make update-examples

# On host (requires GoFSH)
gofsh --useFHIRVersion=4.0.1 examples/ --out input/fsh/
```

### Creating New Resources

1. **Add a new profile**:
   - Create `input/fsh/profiles/ozo-resourcename.fsh`
   - Define profile constraints and extensions
   - Build to validate

2. **Add example instances**:
   - Create JSON in `examples/` directory
   - Run `make update-examples` (inside container) to convert to FSH
   - Review and edit generated FSH in `input/fsh/instances/`
   - Build to validate

3. **Add documentation pages**:
   - Create `input/pagecontent/your-page.md`
   - Add entry to `sushi-config.yaml` under `pages:`
   - Add menu entry under `menu:` if needed
   - Build to view

4. **Add diagrams**:
   - Create `.plantuml` file in `input/images-source/`
   - Build (diagrams auto-generated to `input/images/`)
   - Reference in markdown: `![Description](images/your-diagram.svg)`

### Local Development Workflow

The recommended workflow is to use the Docker container for all builds:

```bash
# 1. Make changes to FSH files
vim input/fsh/profiles/ozo-patient.fsh

# 2. Build and test
sh build_with_image.sh

# 3. View in browser (opens automatically)

# 4. Iterate on changes
```

For faster iteration, you can work inside an interactive container session:

```bash
# Start interactive session
docker run -it --entrypoint /bin/bash \
  -v "${PWD}:/src" \
  registry.gitlab.com/headease/ozo-refererence-impl/ozo-implementation-guide/main:latest

# Inside container: make changes and build
vim input/fsh/profiles/ozo-patient.fsh
make validate  # Quick validation
make build     # Full build
```

## Standards & Compliance

### FHIR Version
- **FHIR R4** (4.0.1)

### Dependencies
- **NL-core profiles** v0.11.0-beta.1 - Dutch healthcare localization (Nictiz)
- **HL7 FHIR Core** - Base FHIR R4 specification

### Security & Compliance Standards
- **Nuts Protocol**: Decentralized authentication/authorization for Dutch healthcare
- **NEN7510**: Dutch healthcare information security standard
- **mTLS**: Mutual TLS for system-to-system authentication
- **DPoP**: Demonstrating Proof of Possession for OAuth 2.0 tokens
- **W3C Trace Context**: Distributed tracing standard for healthcare networks

### Authentication Patterns

The OZO platform supports three distinct access patterns:

1. **OZO System Access**: System-to-system authentication via mTLS
2. **Practitioner Access**: Healthcare professional authentication via Nuts protocol
3. **RelatedPerson Access**: Informal caregiver authentication via OZO-specific flows

See the Implementation Guide documentation for detailed authentication and authorization flows.

## Documentation Topics

The Implementation Guide includes comprehensive documentation:

- **Authentication Flows**:
  - Practitioner authentication with Nuts protocol
  - RelatedPerson authentication patterns
  - mTLS setup and configuration
  - Token validation with DPoP

- **Authorization**:
  - Access control patterns for different user types
  - CareTeam-based permissions
  - Resource access scopes

- **Interactions**:
  - FHIR network creation and management
  - Messaging interactions and threading
  - Task assignment and workflow
  - Dropbox attachment handling

- **Compliance**:
  - NEN7510 audit event implementation
  - W3C Trace Context integration
  - Privacy and security considerations

## GitLab CI/CD

This repository uses GitLab CI/CD for continuous integration and deployment to GitLab Pages.

### Automated Builds

- **Triggers**: Automatically on push to any branch
- **Build Process**:
  1. Pulls the latest builder Docker image
  2. Runs `make build` inside the container
  3. SUSHI compiles FSH files
  4. PlantUML generates diagrams
  5. IG Publisher creates the documentation
  6. Publishes to GitLab Pages (main branch only)

### Deployment

This project is deployed to two locations:

#### GitHub Pages (Primary)
- **URL**: `https://ozo-implementation-guide.headease.nl`
- **Workflow**: `.github/workflows/build_deploy.yml`
- **Trigger**: Automatic on push to `main` branch
- **DNS**: Custom domain pointing to `ozoverbindzorg.github.io`

#### GitLab Pages (Secondary)
- **URL**: `https://ozo-implementation-guide-405d2b.gitlab.io`
- **Workflow**: `.gitlab-ci.yml`
- **Trigger**: Automatic on push to `main` branch
- **Purpose**: Alternative deployment and CI/CD testing

## Troubleshooting

### Build Failures

**Problem**: Build fails with missing dependencies

**Solution**:
```bash
# Rebuild Docker image with latest dependencies
docker build --no-cache -t ozo-ig-builder .

# Or pull latest pre-built image
docker pull registry.gitlab.com/headease/ozo-refererence-impl/ozo-implementation-guide/main:latest
```

### FSH Validation Errors

**Problem**: SUSHI reports validation errors

**Solution**:
```bash
# Inside container, run validation
docker run -it --entrypoint /bin/bash \
  -v "${PWD}:/src" \
  registry.gitlab.com/headease/ozo-refererence-impl/ozo-implementation-guide/main:latest

# Then inside container
make validate
```

### Diagram Generation Issues

**Problem**: PlantUML diagrams not generating

**Solution**: Diagrams are generated automatically during the build. Check that:
- `.plantuml` files exist in `input/images-source/`
- Graphviz is installed in the Docker image
- No syntax errors in PlantUML files

### Memory Issues with IG Publisher

**Problem**: Java runs out of memory during build

**Solution**:
```bash
# Increase Docker memory limits
docker run --memory="4g" --rm -v "${PWD}:/src" \
  registry.gitlab.com/headease/ozo-refererence-impl/ozo-implementation-guide/main:latest
```

### Volume Mounting Issues

**Problem**: Changes not reflected in build

**Solution**: Ensure you're mounting the entire project directory:
```bash
docker run --rm -v "${PWD}:/src" <image-name>
```
The container expects the project root at `/src` and will read all files from there.

## Contributing

When contributing to this project:

1. Always edit FSH files, not generated JSON/XML
2. Follow existing naming conventions for resources (ozo-resourcename)
3. Update documentation pages when adding new features
4. Ensure all examples validate against profiles
5. Run the full build before committing changes
6. Test locally with Docker before pushing to GitLab

For detailed development guidelines, see [CLAUDE.md](CLAUDE.md).

## Docker Image Details

The Docker image includes all required tools:
- **.NET SDK 8.0** with Firely Terminal
- **Java (OpenJDK)** for the IG Publisher
- **Node.js** with FHIR Shorthand (SUSHI)
- **Ruby/Jekyll** for static site generation
- **Python 3** with YAML support
- **Graphviz** for diagram generation
- **PlantUML** for sequence diagrams
- **Saxon HE** and XML Resolver for XSLT processing

The image is automatically built and published to the GitLab Container Registry.

## Technical Details

- **Single Source**: FSH files as primary authoring format
- **Automated Generation**: SUSHI compiles FSH to FHIR JSON/XML
- **Diagram Support**: PlantUML for sequence and class diagrams
- **Static Site**: Jekyll generates human-readable HTML documentation
- **Version Control**: Semantic versioning in `sushi-config.yaml`
- **CI/CD**: Automated builds and deployments via GitLab CI
- **Makefile**: All build commands run inside the container

## License

[License information to be added]

## Contact

**Maintainer**: roland@headease.nl

**Organization**: HeadEase

**Project**: OZO Reference Implementation

For questions, issues, or contributions, please contact the maintainer or open an issue in the repository.
