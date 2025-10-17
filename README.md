# OZO FHIR Implementation Guide

A healthcare implementation guide for the OZO platform that connects care professionals with informal caregivers using FHIR R4 standards.

## Overview

The OZO FHIR Implementation Guide documents a healthcare communication platform that bridges formal healthcare networks with patients' informal social environments. The platform enables secure messaging, task management, and care coordination between healthcare professionals and informal caregivers (family members, friends).

This implementation guide covers:

- **Authentication & Authorization**: Integration with the Nuts protocol for decentralized healthcare authentication
- **Messaging**: FHIR-based communication patterns between practitioners and caregivers
- **Security & Audit**: NEN7510-compliant audit logging with W3C Trace Context support
- **Dutch Healthcare Compliance**: Built on NL-core profiles for Dutch healthcare standards

## Local Development

### Building the IG Locally with Docker

You can build and test the Implementation Guide locally using Docker. This is useful for development and testing before pushing changes.

#### Prerequisites
- Docker installed on your system
- All source files in the `input/` directory

#### Quick Build (Recommended)

The fastest way to build the IG is using the pre-built Docker image:

```bash
sh build_with_image.sh
```

Alternatively, using Make:

```bash
make build
```

#### Build the Docker Image

If you need to rebuild the Docker image with custom dependencies:

```bash
docker build . -t ozo-ig-builder
```

This creates a Docker image named `ozo-ig-builder` with all the required dependencies (Java, Node.js, Ruby/Jekyll, SUSHI, IG Publisher, Graphviz).

#### Run the Build Manually

To build the Implementation Guide manually with Docker:

```bash
docker run --rm --name=ozo-ig-builder \
  -v ./input:/app/input \
  -v ./output:/app/output \
  -v ./public:/app/public \
  -v ./ig.ini:/app/ig.ini \
  -v ./sushi-config.yaml:/app/sushi-config.yaml \
  ozo-ig-builder
```

This command:
- Mounts the `input/` directory containing your FHIR resources
- Mounts the `output/` and `public/` directories where the built IG will be placed
- Mounts the `ig.ini` and `sushi-config.yaml` configuration files
- Runs SUSHI to compile FSH files
- Generates PlantUML diagrams
- Runs the IG Publisher to generate the output

#### View the Results

After the build completes:
- Open `public/index.html` in a web browser to view the IG
- Check `output/qa.html` for validation results and quality checks
- Review the console output for detailed build information

#### Clean Output Directory

Before rebuilding, you may want to clean the output directories:

```bash
rm -rf ./output/* ./public/* ./temp/* ./fsh-generated/*
```

## Project Structure

```
ozo-implementation-guide/
├── input/
│   ├── fsh/
│   │   ├── profiles/          # FHIR profile definitions
│   │   ├── instances/         # Example resources
│   │   └── aliases.fsh        # Common aliases
│   ├── pagecontent/           # Markdown documentation pages
│   └── images-source/         # PlantUML diagram sources
├── examples/                  # JSON example resources
├── output/                    # Full IG Publisher output (not in git)
├── public/                    # Simplified output (not in git)
├── fsh-generated/             # SUSHI output (not in git)
├── temp/                      # Build artifacts (not in git)
├── sushi-config.yaml          # Main IG configuration
├── ig.ini                     # IG Publisher configuration
├── Dockerfile                 # Build environment definition
├── Makefile                   # Build automation
└── build_with_image.sh        # Docker build script
```

## Key FHIR Resources

The OZO platform data model includes:

- **Patient**: Identified by BSN (Dutch citizen service number)
- **RelatedPerson**: Informal caregivers linked to patients
- **Practitioner**: Healthcare professionals
- **Organization**: Healthcare organizations
- **CareTeam**: Groups of practitioners and related persons
- **Communication/CommunicationRequest**: Threaded messaging system
- **Task**: Work assignments and referrals
- **AuditEvent**: NEN7510-compliant audit logging with W3C Trace Context

## Development

### Working with FHIR Shorthand (FSH)

This project uses FSH as the primary authoring format. Always edit `.fsh` files rather than generated JSON.

To convert JSON examples back to FSH:

```bash
make update-examples
```

Or manually using GoFSH:

```bash
gofsh --useFHIRVersion=4.0.1 examples/ --out input/fsh/
```

### Creating New Examples

1. Create JSON file in `examples/` directory
2. Run `make update-examples` to generate FSH
3. Review and edit generated FSH in `input/fsh/instances/`
4. Build the IG to validate

### Adding Documentation Pages

1. Create markdown file in `input/pagecontent/`
2. Add entry to `sushi-config.yaml` under `pages:`
3. Add menu entry under `menu:` if needed
4. Rebuild the IG

### Creating Diagrams

1. Add `.plantuml` file to `input/images-source/`
2. Build the IG (diagrams are auto-generated to `input/images/`)
3. Reference in markdown: `![Description](images/your-diagram.svg)`

Manual diagram generation:

```bash
plantuml -o ../images/ -tsvg ./input/images-source/*.plantuml
```

## Generating FSH FHIR Resources on Your Desktop

If you want to generate FSH FHIR resources based on Simplifier FHIR profiles (like the Dutch 'nl-core' profiles) on your local desktop, you need to install the required tools:

### Install Dotnet & Firely Terminal

```bash
sudo apt-get install -y dotnet-sdk-8.0
echo 'export PATH=$PATH:~/.dotnet/tools' >> ~/.bashrc
source ~/.bashrc
```

Create a snapshot of the Dutch profiles:

```bash
fhir install nictiz.fhir.nl.r4.nl-core 0.11.0-beta.1
```

### Install NodeJS & SUSHI

[Install NodeJS & Sushi](https://fshschool.org/docs/sushi/installation/) to generate FHIR resources from FSH files:

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &&\
sudo apt-get install -y nodejs
sudo npm install -g npm@latest
sudo npm install -g fsh-sushi
```

Now you can generate FHIR resources from FSH files using:

```bash
sushi .
```

## Standards & Compliance

### FHIR Version
- **FHIR R4** (4.0.1)

### Dependencies
- **NL-core profiles** v0.11.0-beta.1 (Dutch healthcare localization)
- **Nuts protocol**: Decentralized authentication/authorization for Dutch healthcare

### Security Standards
- **NEN7510**: Dutch healthcare information security standard
- **mTLS**: Mutual TLS for system-to-system authentication
- **DPoP**: Demonstrating Proof of Possession for OAuth tokens
- **W3C Trace Context**: Distributed tracing across healthcare networks

## Publishing

The implementation guide is published to GitLab Pages with automated CI/CD via `.gitlab-ci.yml`.

**Canonical URL**: `http://headease.gitlab.io/ozo-refererence-impl/ozo-implementation-guide`

## Documentation Topics

The implementation guide includes detailed documentation on:

- Practitioner and RelatedPerson authentication flows
- Authorization patterns for different user types
- mTLS setup and configuration
- Token validation with DPoP
- FHIR network creation and management
- Messaging interactions and threading
- Dropbox attachment handling
- NEN7510 audit event compliance
- W3C Trace Context integration

## Contributing

When contributing to this project:

1. Always edit FSH files, not generated JSON
2. Follow existing naming conventions for resources
3. Update documentation pages when adding new features
4. Ensure all examples validate against profiles
5. Run the full build before committing changes

For detailed guidance on working with this codebase, see [CLAUDE.md](CLAUDE.md).

## License

[License information to be added]

## Contact

[Contact information to be added]
