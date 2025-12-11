# Makefile for OZO FHIR Implementation Guide
# This Makefile is designed to run INSIDE the Docker container

# Variables
FHIR := fhir
DOTNET_TOOLS := $(HOME)/.dotnet/tools

# Fetch version from sushi-config.yaml with error handling
export VERSION := $(shell grep '^version:' sushi-config.yaml | sed 's/version: //' | tr -d '[:space:]')
ifeq ($(VERSION),)
$(error "Could not extract version from sushi-config.yaml")
endif

# Export PATH with dotnet tools
export PATH := $(PATH):$(DOTNET_TOOLS)

# Default target
.PHONY: all
all: build

# Build target (full documentation package)
.PHONY: build
build: install-dependencies build-ig
	@echo "Build complete!"

# Build minimal package (without narratives)
.PHONY: build-minimal
build-minimal: install-dependencies build-ig-minimal

# Install FHIR dependencies
.PHONY: install-dependencies
install-dependencies:
	@echo "Installing dependencies from sushi-config.yaml..."
	@python3 scripts/get_dependencies.py | while read pkg; do \
		echo "Installing $$pkg..."; \
		fhir install $$pkg; \
		fhir extract-package $$pkg; \
		fhir inflate --package $$pkg; \
	done

# Copy changelog to pagecontent for IG inclusion
.PHONY: copy-changelog
copy-changelog:
	@echo "Copying CHANGELOG.md to input/pagecontent/history.md..."
	@cp CHANGELOG.md input/pagecontent/history.md

# Build Implementation Guide using IG Publisher
.PHONY: build-ig
build-ig: copy-changelog
	@echo "Building OZO Implementation Guide with version $(VERSION)..."
	@echo "Running SUSHI to compile FSH files..."
	@sushi .
	@echo "Generating PlantUML diagrams..."
	@if command -v plantuml >/dev/null 2>&1; then \
		mkdir -p ./input/images; \
		plantuml -o ../images/ -tsvg ./input/images-source/*.plantuml 2>/dev/null || true; \
	fi
	@echo "Running IG Publisher..."
	@java -jar /usr/local/publisher.jar -ig ig.ini
	@if [ ! -f ./output/package.tgz ]; then \
		echo "ERROR: Build did not create ./output/package.tgz"; \
		exit 1; \
	fi
	@echo "Copying package.tgz to: ./output/fhir.ozo-$(VERSION).tgz"
	@cp ./output/package.tgz ./output/fhir.ozo-$(VERSION).tgz
	@echo "Successfully created: ./output/fhir.ozo-$(VERSION).tgz"
	@echo "IG Publisher completed successfully"

# Build Implementation Guide (Minimal for servers with snapshots)
# This target creates a minimal FHIR package optimized for FHIR server deployment by:
# 1. Using SUSHI/IG Publisher to generate resources with snapshots
# 2. Converting IG Publisher output back to package.json using Python script
# 3. Stripping only narratives and mappings while keeping snapshots
# 4. Creating final package without regenerating snapshots
.PHONY: build-ig-minimal
build-ig-minimal: install-dependencies build-ig convert-ig-minimal pack-minimal

# Convert ImplementationGuide back to package.json for minimal package using Python script
.PHONY: convert-ig-minimal
convert-ig-minimal:
	@echo "Converting ImplementationGuide to minimal package.json using Python script..."
	@python3 scripts/convert_ig_to_package.py output/ImplementationGuide-fhir.ozo.json package.json

# Pack FHIR resources for minimal package using Firely CLI (keeping snapshots, removing only narratives/mappings)
.PHONY: pack-minimal
pack-minimal:
	@echo "Creating minimal FHIR package with snapshots retained..."
	@mkdir -p output-minimal
	@echo "Restoring package dependencies..."
	$(FHIR) restore
	@echo "Copying FHIR resources from output to output-minimal..."
	@find output -name "*.json" -type f -not -name "*usage-stats*" -not -name "*qa*" -not -name "*manifest*" -not -name "*fragment*" -not -name "*canonicals*" -not -name "*list*" -not -name "*expansions*" -exec cp {} output-minimal/ \;
	@echo "Stripping narratives and mappings from FHIR resources (keeping snapshots)..."
	@python3 scripts/strip_narratives.py output-minimal/ --keep-snapshots
	@echo "Verifying minimal package creation..."
	@if [ -f output-minimal/StructureDefinition-OZOAuditEvent.json ]; then \
		SIZE=$$(wc -c < output-minimal/StructureDefinition-OZOAuditEvent.json); \
		echo "StructureDefinition-OZOAuditEvent.json is $$SIZE bytes (with snapshots retained)"; \
	fi
	@echo "Copying package.json to output-minimal..."
	@cp package.json output-minimal/
	@echo "Creating minimal package manually (avoiding Firely CLI snapshot regeneration)..."
	@echo "Preparing package structure..."
	@mkdir -p output-minimal/package
	@echo "Moving stripped JSON files to package directory..."
	@find output-minimal -maxdepth 1 -name "*.json" -type f ! -name "package.json" -exec mv {} output-minimal/package/ \;
	@echo "Moving package.json to package directory..."
	@mv output-minimal/package.json output-minimal/package/
	@echo "Creating .index.json..."
	@cd output-minimal && python3 ../scripts/create_index.py
	@echo "Creating package tarball..."
	@cd output-minimal && tar -czf fhir.ozo.$(VERSION).tgz package/
	@echo "Verifying minimal package was created..."
	@if ! ls output-minimal/*.tgz >/dev/null 2>&1; then \
		echo "ERROR: Minimal package creation failed - no .tgz file found"; \
		exit 1; \
	fi
	@echo "Renaming generated package for GitHub Actions compatibility..."
	@cd output-minimal && \
	for file in *.tgz; do \
		if [ -f "$$file" ]; then \
			cp "$$file" package.tgz; \
			cp "$$file" fhir.ozo-$(VERSION)-minimal.tgz; \
			break; \
		fi; \
	done
	@echo "Successfully created minimal FHIR package: ./output-minimal/fhir.ozo-$(VERSION)-minimal.tgz"
	@echo "Package also available as: ./output-minimal/package.tgz"
	@echo "Final package size: $$(du -h ./output-minimal/fhir.ozo-$(VERSION)-minimal.tgz | cut -f1)"
	@echo "Package structure matches working Simplifier format - ready for HAPI FHIR deployment"

# Convert JSON examples to FSH using GoFSH
.PHONY: update-examples
update-examples:
	@echo "Converting JSON examples to FSH..."
	@if ! command -v gofsh >/dev/null 2>&1; then \
		echo "Error: GoFSH not found. Install it with: npm install -g gofsh"; \
		exit 1; \
	fi
	@gofsh --useFHIRVersion=4.0.1 examples/ --out input/fsh/
	@echo "Examples converted successfully"

# Generate PlantUML diagrams
.PHONY: diagrams
diagrams:
	@echo "Generating PlantUML diagrams..."
	@if ! command -v plantuml >/dev/null 2>&1; then \
		echo "Error: plantuml not found. Please install it first."; \
		exit 1; \
	fi
	@mkdir -p ./input/images
	@plantuml -o ../images/ -tsvg ./input/images-source/*.plantuml
	@echo "Diagrams generated successfully in input/images/"

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf ./output/* ./public/* ./temp/* ./fsh-generated/*
	@echo "Clean complete"

# Deep clean including caches
.PHONY: clean-all
clean-all: clean
	@echo "Performing deep clean..."
	@rm -rf ./input-cache/*
	@echo "Deep clean complete"

# Validate FSH files
.PHONY: validate
validate:
	@echo "Validating FSH files with SUSHI..."
	@sushi . --snapshot
	@echo "Validation complete"

# Show version
.PHONY: version
version:
	@echo "OZO Implementation Guide Version: $(VERSION)"

# Help target
.PHONY: help
help:
	@echo "OZO FHIR Implementation Guide - Available Make Targets"
	@echo ""
	@echo "This Makefile is designed to run INSIDE the Docker container."
	@echo "For instructions on running from the host machine, see README.md"
	@echo ""
	@echo "Building:"
	@echo "  make build           - Build IG (calls install-dependencies and build-ig)"
	@echo "  make build-minimal   - Build minimal package with snapshots but without narratives/mappings (for FHIR servers)"
	@echo "  make build-ig        - Build Implementation Guide and create installable package"
	@echo "                         Creates: ./output/fhir.ozo-$(VERSION).tgz"
	@echo "  make build-ig-minimal - Build minimal Implementation Guide package"
	@echo "                         Creates: ./output-minimal/fhir.ozo-$(VERSION)-minimal.tgz"
	@echo "  make install-dependencies - Install FHIR dependencies"
	@echo ""
	@echo "Development:"
	@echo "  make update-examples - Convert JSON examples to FSH using GoFSH"
	@echo "  make diagrams        - Generate PlantUML diagrams"
	@echo "  make validate        - Validate FSH files with SUSHI"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean           - Clean build artifacts"
	@echo "  make clean-all       - Deep clean including caches"
	@echo "  make version         - Show current version from sushi-config.yaml"
	@echo ""
	@echo "Information:"
	@echo "  make help            - Show this help message"
	@echo ""
	@echo "Current version: $(VERSION)"
