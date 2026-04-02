# Installing OZO FHIR Package in HAPI FHIR Server

This manual provides step-by-step instructions for installing the OZO FHIR Implementation Guide package in a HAPI FHIR server.

## Overview

The OZO FHIR Implementation Guide is distributed as a packaged release that can be installed on HAPI FHIR servers to enable validation and support for OZO-specific profiles, extensions, and resources.

## Prerequisites

- HAPI FHIR Server v8.6.0 or later (FHIR R4)
- Java 17 or higher
- PostgreSQL database (or another supported database)
- Access to the HAPI FHIR server configuration files

## Installation Methods

There are two primary methods for installing the OZO FHIR package on your HAPI FHIR server:

1. **Configuration-based installation** (recommended for production)
2. **Runtime installation via API** (for testing and development)

---

## Method 1: Configuration-Based Installation (Recommended)

This method involves configuring the HAPI FHIR server's `application.yaml` file to automatically download and install the OZO FHIR package on server startup.

### Step 1: Locate the Release Package

Visit the OZO FHIR Implementation Guide releases page:
- **Repository:** [https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/releases](https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/releases)
- **Latest Release:** [v0.7.2](https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/releases/tag/v0.7.2)

From the release page, copy the URL of the `.tgz` package file. For production servers, use the **minimal** package (smaller, optimized for server deployment):
```
fhir.ozo-0.7.2-minimal.tgz
```

The full download URL will be:
```
https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/releases/download/v0.7.2/fhir.ozo-0.7.2-minimal.tgz
```

### Step 2: Configure the HAPI FHIR Server

Open your HAPI FHIR server's `application.yaml` configuration file, typically located at:
```
src/main/resources/application.yaml
```

Navigate to the `hapi.fhir.implementationguides` section and add the OZO package configuration:

```yaml
hapi:
  fhir:
    # ... other HAPI configuration ...

    # Do NOT enable fetchDependencies or install_transitive_ig_dependencies.
    # Transitive dependencies include hl7.fhir.r4.core and hl7.fhir.uv.extensions.r4
    # which contain SearchParameter resources referencing R5-only types (e.g. DeviceUsage,
    # DomainResource) that crash HAPI R4 during installation.
    install_transitive_ig_dependencies: false

    # Disable validation during package installation to bypass snapshot generation issues
    iginstaller_validationenabled: false

    # Flag filters resources during package installation
    validate_resource_status_for_package_upload: false

    implementationguides:
      # Store the R4 extensions package without installing — it contains SearchParameter
      # resources that reference R5-only types (DeviceUsage) which crash HAPI R4
      r4-extensions:
        name: hl7.fhir.uv.extensions.r4
        version: 1.0.0
        installMode: STORE_ONLY

      # Dutch ZIB 2020 profiles (dependency of NL-core)
      zib2020:
        name: nictiz.fhir.nl.r4.zib2020
        version: 0.12.0-beta.4
        installMode: STORE_AND_INSTALL

      # Dutch NL-core profiles (dependency of NL-GF and OZO)
      nl-core:
        name: nictiz.fhir.nl.r4.nl-core
        version: 0.12.0-beta.4
        installMode: STORE_AND_INSTALL

      # OZO FHIR Implementation Guide
      ozo:
        name: fhir.ozo
        version: 0.7.2
        packageUrl: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/releases/download/v0.7.2/fhir.ozo-0.7.2-minimal.tgz
        installMode: STORE_AND_INSTALL
```

> **Important:** Do **not** use `fetchDependencies: true` or `install_transitive_ig_dependencies: true`. These settings cause HAPI to pull in `hl7.fhir.r4.core` and `hl7.fhir.uv.extensions.r4` which contain SearchParameter resources referencing R5-only types (`DeviceUsage`, `DomainResource`), crashing the server. Instead, list all required dependencies explicitly as shown above.
{:.stu-note}


#### Configuration Parameters Explained

| Parameter | Description | Recommended Value |
|-----------|-------------|-------------------|
| **name** | The package identifier (must match the package ID) | `fhir.ozo` |
| **version** | The version of the package to install | `0.7.2` |
| **packageUrl** | Direct URL to the `.tgz` package file | Release download URL |
| **installMode** | How to handle the package installation | `STORE_AND_INSTALL` |

#### Install Modes

- **STORE_ONLY**: Downloads and stores the package but does not install resources
- **STORE_AND_INSTALL**: Downloads, stores, and installs all resources (recommended)

### Step 3: Configure Validation Settings

The OZO package includes custom profiles and extensions. To ensure proper installation, add or verify these settings in your `application.yaml`:

```yaml
hapi:
  fhir:
    # Enable repository validation to validate resources against OZO profiles
    enable_repository_validating_interceptor: true

    # Disable validation during IG installation to avoid snapshot issues
    iginstaller_validationenabled: false

    # Allow installation of resources regardless of status
    validate_resource_status_for_package_upload: false

    # Profile validation mode for the repository validating interceptor
    validation:
      data:
        profile_mode: DECLARED  # or ENFORCED for strict environments
```

#### Profile validation modes

The `profile_mode` setting controls how the HAPI server validates resources against OZO profiles:

| Mode | Behavior |
|------|----------|
| **`ENFORCED`** | Resources **must** declare a `meta.profile` matching an installed profile. Resources without a profile are rejected. Recommended for production environments where all resources must conform to OZO profiles. |
| **`DECLARED`** | Resources are validated against the profile declared in `meta.profile`, but resources without a profile are accepted. Recommended for environments that also accept non-OZO resources. |
| **`OPTIONAL`** | Profiles are checked if present but validation errors are downgraded to warnings. |
| **`TRUST`** | Profiles are not validated. |
| **`OFF`** | Profile validation is completely disabled. |

> **Recommendation:** Use `DECLARED` during initial setup and migration. Switch to `ENFORCED` once all clients consistently set `meta.profile` on their resources.
{:.stu-note}

### Step 4: Restart the HAPI FHIR Server

After updating the configuration:

1. **Save** the `application.yaml` file
2. **Rebuild** your HAPI FHIR server application:
   ```bash
   mvn clean install
   ```
3. **Restart** the server:
   ```bash
   java -jar target/hapi-fhir-jpaserver.jar
   ```

### Step 5: Verify Installation

Once the server has restarted, verify that the OZO package was installed successfully:

#### Check Server Logs

Look for log entries indicating successful package installation:
```
INFO: Installing package fhir.ozo version 0.7.2
INFO: Successfully installed implementation guide: fhir.ozo
```

#### Query the ImplementationGuide Resource

Use the FHIR API to verify the ImplementationGuide was loaded:
```bash
curl http://localhost:8080/fhir/ImplementationGuide?_id=fhir.ozo
```

You should receive a response containing the OZO ImplementationGuide resource.

#### Check Installed Profiles

Verify that OZO profiles are available:
```bash
curl http://localhost:8080/fhir/StructureDefinition?url=http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCareTeam
```

### Version Discovery

After installation, you may want to determine which version of the OZO IG is active on the server. There are several approaches depending on your HAPI configuration.

#### Query StructureDefinitions (works out of the box)

All OZO profiles share the same `version` field, which matches the installed IG package version. Query them with:

```bash
curl "http://localhost:8080/fhir/StructureDefinition?url:below=http://ozoverbindzorg.nl/fhir/StructureDefinition&_elements=url,version,name&_sort=name"
```

The `version` field on each returned StructureDefinition reflects the IG package version (e.g., `"version": "0.7.2"`).

#### Query the ImplementationGuide resource

If the `ImplementationGuide` resource type is enabled on your server (see below), you can query it directly:

```bash
curl "http://localhost:8080/fhir/ImplementationGuide?name=ozo-implementation-guide"
```

By default, HAPI's `supported_resource_types` may not include `ImplementationGuide`. To enable it, add it to your `application.yaml`:

```yaml
hapi:
  fhir:
    supported_resource_types:
      - ImplementationGuide
      # ... other resource types
```

#### Known limitation: CapabilityStatement

HAPI FHIR does not automatically populate the `implementationGuide` field in the CapabilityStatement (`/fhir/metadata`). The StructureDefinition query above is the most reliable method for version discovery.

---

## Creating Resources with OZO Profiles

After installing the OZO package, you can create FHIR resources that conform to OZO profiles. To ensure proper validation, you must set the `meta.profile` element to the canonical URL of the OZO profile.

### Example: Creating an OZO CareTeam Resource

OZO defines two CareTeam profiles:
* **OZOCareTeam** — patient care networks (requires `subject`)
* **OZOOrganizationalCareTeam** — organizational teams for team-to-team messaging (no `subject`, requires `managingOrganization`)

The OZO CareTeam profile (patient) has the following canonical URL:
```
http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCareTeam
```

#### Step 1: Prepare the JSON Resource

Create a JSON file (e.g., `careteam-example.json`) with the `meta.profile` element set to the OZO profile URL:

```json
{
  "resourceType": "CareTeam",
  "meta": {
    "profile": [
      "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCareTeam"
    ]
  },
  "status": "active",
  "subject": {
    "reference": "Patient/example-patient",
    "type": "Patient",
    "display": "H. de Boer"
  },
  "participant": [
    {
      "member": {
        "reference": "RelatedPerson/example-relatedperson",
        "type": "RelatedPerson",
        "display": "Kees Groot"
      }
    },
    {
      "member": {
        "reference": "Practitioner/example-practitioner",
        "type": "Practitioner",
        "display": "Manu van Weel"
      },
      "onBehalfOf": {
        "reference": "Organization/example-hospital",
        "type": "Organization",
        "display": "Ziekenhuis Amsterdam"
      }
    }
  ]
}
```

#### Step 2: POST the Resource to HAPI FHIR

Use `curl` to POST the resource to your HAPI FHIR server:

```bash
curl -X POST http://localhost:8080/fhir/CareTeam \
  -H "Content-Type: application/fhir+json" \
  -d @careteam-example.json
```

#### Step 3: Verify Validation

The HAPI FHIR server will validate the resource against the OZO CareTeam profile. If the resource does not conform to the profile constraints, you will receive an OperationOutcome with validation errors.

**Successful Response:**
```json
{
  "resourceType": "CareTeam",
  "id": "12345",
  "meta": {
    "versionId": "1",
    "lastUpdated": "2024-12-05T10:30:00.000+00:00",
    "profile": [
      "http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCareTeam"
    ]
  },
  "status": "active",
  "subject": {
    "reference": "Patient/example-patient",
    "type": "Patient",
    "display": "H. de Boer"
  },
  "participant": [...]
}
```

**Validation Error Example:**
```json
{
  "resourceType": "OperationOutcome",
  "issue": [
    {
      "severity": "error",
      "code": "invalid",
      "diagnostics": "CareTeam.subject: minimum required = 1, but only found 0",
      "expression": [
        "CareTeam.subject"
      ]
    }
  ]
}
```

### OZO Profile Canonical URLs

The following table lists the canonical URLs for common OZO profiles:

| Profile Name | Canonical URL |
|--------------|---------------|
| **OZOCareTeam** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCareTeam` |
| **OZOOrganizationalCareTeam** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOOrganizationalCareTeam` |
| **OZOAuditEvent** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOAuditEvent` |
| **OZOPatient** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPatient` |
| **OZOPractitioner** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner` |
| **OZORelatedPerson** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson` |
| **OZOOrganization** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOOrganization` |
| **OZOCommunication** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication` |
| **OZOTask** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask` |
| **OZODevice** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZODevice` |

### Important Notes

1. **Always set meta.profile**: The `meta.profile` element tells the HAPI FHIR server which profile to validate against.

5. **Example resources are installed**: The OZO IG package includes example resources (Patients, Practitioners, Communications, etc.) that are installed alongside profiles when using `STORE_AND_INSTALL`. These are identifiable by their well-known IDs (e.g., `H-de-Boer`, `Manu-van-Weel`). To avoid example data on a production server, delete the example resources after installation or use a post-install script to remove resources without a production-issued ID.

2. **Profile constraints**: Each OZO profile has specific constraints (cardinality, required elements, value sets). Review the profile definition in the [Artifacts](artifacts.html) section.

3. **Referenced resources**: OZO profiles often reference other OZO profiles (e.g., OZOCareTeam references OZOPatient, OZOPractitioner). Ensure all referenced resources also conform to their respective OZO profiles.

4. **Validation mode**: The HAPI server's `enable_repository_validating_interceptor` setting determines whether validation is enforced. If set to `true`, invalid resources will be rejected.

---

## Method 2: Runtime Installation via API

This method is useful for development and testing environments where you want to manually install the package without modifying server configuration.

### Prerequisites

Enable runtime IG upload in your `application.yaml`:
```yaml
hapi:
  fhir:
    ig_runtime_upload_enabled: true
```

### Step 1: Download the Package

Download the `.tgz` package from the releases page:
```bash
wget https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/releases/download/v0.7.2/fhir.ozo-0.7.2.tgz
```

### Step 2: Upload via FHIR API

Use the `$install` operation to upload the package:

```bash
curl -X POST \
  -H "Content-Type: application/gzip" \
  --data-binary @fhir.ozo-0.7.2.tgz \
  "http://localhost:8080/fhir/ImplementationGuide/\$install"
```

### Step 3: Verify Installation

Follow the same verification steps as in Method 1.

---

## Package Dependencies

The OZO FHIR Implementation Guide depends on the following packages. All dependencies **must** be listed explicitly in `application.yaml` (see [Step 2](#step-2-configure-the-hapi-fhir-server)):

| Package                          | Version       | Install Mode        | Description                                    |
|----------------------------------|---------------|---------------------|------------------------------------------------|
| **hl7.fhir.uv.extensions.r4**   | 1.0.0         | `STORE_ONLY`        | FHIR R4 extensions (store only — see warning below) |
| **nictiz.fhir.nl.r4.zib2020**   | 0.12.0-beta.4 | `STORE_AND_INSTALL` | Dutch Health and Care Information models (ZIB) |
| **nictiz.fhir.nl.r4.nl-core**   | 0.12.0-beta.4 | `STORE_AND_INSTALL` | Dutch national core profiles                   |

These dependencies are required for proper validation of Dutch healthcare resources used in the OZO platform.

> **Important:** The `hl7.fhir.uv.extensions.r4` package **must** use `STORE_ONLY` install mode. This package contains SearchParameter resources that reference FHIR R5-only types (`DeviceUsage`, `DomainResource`) which are not valid in R4. Using `STORE_AND_INSTALL` will crash the server with `HAPI-1684: Unknown resource name "DeviceUsage"`.
{:.stu-note}


---

## Troubleshooting

### Issue: Package Installation Fails with Validation Errors

**Solution:** Ensure validation is disabled during installation:
```yaml
hapi:
  fhir:
    iginstaller_validationenabled: false
```

### Issue: Snapshot Generation Errors

**Solution:** The HAPI FHIR server may have issues generating snapshots for certain profiles. The `iginstaller_validationenabled: false` setting helps bypass this issue.

### Issue: Server Crashes with `HAPI-1684: Unknown resource name "DeviceUsage"` or `"DomainResource"`

**Cause:** The `hl7.fhir.uv.extensions.r4` or `hl7.fhir.r4.core` packages contain SearchParameter resources that reference FHIR R5-only types. This happens when `fetchDependencies: true` or `install_transitive_ig_dependencies: true` causes HAPI to pull in and install these packages.

**Solution:** Do **not** use `fetchDependencies` or `install_transitive_ig_dependencies`. Instead, list all dependencies explicitly and use `STORE_ONLY` for the extensions package:

```yaml
install_transitive_ig_dependencies: false

implementationguides:
  r4-extensions:
    name: hl7.fhir.uv.extensions.r4
    version: 1.0.0
    installMode: STORE_ONLY
  # ... other dependencies listed explicitly ...
```

See the [complete configuration example](#complete-configuration-example) for the full setup.

### Issue: Database Schema Errors After Upgrading HAPI (NOT NULL constraint violations)

**Cause:** When upgrading HAPI across major versions (e.g., 7.x to 8.x), the database migration tool may not update all column constraints. Columns like `trm_concept_desig.val`, `trm_concept_map_grp_elm_tgt.target_code`, and others may retain stale `NOT NULL` constraints that conflict with newer HAPI code.

**Solution:** Run the HAPI migration tool before starting the upgraded server:

```bash
./hapi-fhir-cli migrate-database \
  -d POSTGRES_9_4 \
  -u "jdbc:postgresql://<host>:<port>/<db>" \
  -n "<username>" \
  -p "<password>"
```

If errors persist, the cleanest approach for a non-production database is to drop and recreate the schema so HAPI creates it fresh:

```sql
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
```

For PostgreSQL, also check for stale CHECK constraints that block newer enum values:

```sql
SELECT conname, conrelid::regclass, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE contype = 'c' AND conrelid::regclass::text LIKE 'trm_%';
```

Drop any that restrict columns to old value ranges (e.g., `trm_concept_property_prop_type_check`).

### Issue: Background Reindexing Errors for Unsupported Resource Types (e.g. `Flag`)

**Cause:** The Nictiz NL-core packages include SearchParameter definitions that reference resource types not in your `supported_resource_types` list. HAPI's background reindexing jobs fail when they encounter these types.

**Solution:** Add the missing resource types to `supported_resource_types`. For NL-core compatibility, add at least `Flag`:

```yaml
supported_resource_types:
  # ... existing types ...
  - Flag
```

Alternatively, remove the `supported_resource_types` setting entirely to allow all R4 resource types (may increase memory usage).

### Issue: Dependencies Not Installed

**Solution:** Ensure all required packages are listed explicitly in `implementationguides`. The server needs internet access to download packages from the FHIR package registry.

### Issue: Out of Memory Errors During Installation

**Solution:** Increase the JVM heap size when starting the HAPI server:
```bash
java -Xmx4g -jar target/hapi-fhir-jpaserver.jar
```

### Issue: Package Not Found After Installation

**Solution:** Check the server logs for installation errors. Verify the package URL is accessible and the package file is valid.

---

## Updating to a New Version

To update to a newer version of the OZO FHIR package:

1. **Update the configuration** in `application.yaml`:
   ```yaml
   implementationguides:
     ozo:
       name: fhir.ozo
       version: X.Y.Z  # New version
       packageUrl: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/releases/download/vX.Y.Z/fhir.ozo-X.Y.Z.tgz
   ```

2. **Restart the HAPI FHIR server**

3. **Verify the new version** is installed:
   ```bash
   curl http://localhost:8080/fhir/ImplementationGuide?_id=fhir.ozo
   ```

The server will detect the version change and reinstall the package with the updated resources.

---

## Complete Configuration Example

Below is a complete example of a HAPI FHIR server `application.yaml` configuration with the OZO package installed:

```yaml
hapi:
  fhir:
    fhir_version: R4
    server_address: http://localhost:8080/fhir/

    # IMPORTANT: Do NOT enable these — transitive dependencies include packages
    # with R5-only SearchParameters that crash HAPI R4
    install_transitive_ig_dependencies: false

    # Enable repository validation
    enable_repository_validating_interceptor: true

    # Disable validation during IG installation
    iginstaller_validationenabled: false
    validate_resource_status_for_package_upload: false

    # Profile validation mode (DECLARED or ENFORCED for production)
    validation:
      data:
        profile_mode: DECLARED

    # Implementation Guides — all dependencies listed explicitly
    implementationguides:
      # Store extensions only — contains R5-only SearchParameters (DeviceUsage,
      # DomainResource) that crash HAPI R4 if installed
      r4-extensions:
        name: hl7.fhir.uv.extensions.r4
        version: 1.0.0
        installMode: STORE_ONLY

      # Dutch ZIB 2020 profiles (dependency of NL-core)
      zib2020:
        name: nictiz.fhir.nl.r4.zib2020
        version: 0.12.0-beta.4
        installMode: STORE_AND_INSTALL

      # Dutch NL-core profiles (dependency of NL-GF and OZO)
      nl-core:
        name: nictiz.fhir.nl.r4.nl-core
        version: 0.12.0-beta.4
        installMode: STORE_AND_INSTALL

      # OZO FHIR Implementation Guide
      ozo:
        name: fhir.ozo
        version: 0.7.2
        packageUrl: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/releases/download/v0.7.2/fhir.ozo-0.7.2-minimal.tgz
        installMode: STORE_AND_INSTALL

    # Supported resource types (ensure OZO resources are included)
    supported_resource_types:
      - AuditEvent
      - CareTeam
      - Communication
      - CommunicationRequest
      - Flag               # Required by NL-core SearchParameter definitions
      - ImplementationGuide  # Enables version discovery via /fhir/ImplementationGuide
      - Organization
      - Patient
      - Practitioner
      - RelatedPerson
      - StructureDefinition  # Enables profile queries for version discovery
      - Task
      # ... other resource types
```

---

## Additional Resources

- **OZO Implementation Guide Documentation:** [https://ozo-implementation-guide.headease.nl](https://ozo-implementation-guide.headease.nl)
- **GitHub Repository:** [https://github.com/ozoverbindzorg/integrale-netwerk-communicatie](https://github.com/ozoverbindzorg/integrale-netwerk-communicatie)
- **HAPI FHIR Documentation:** [https://hapifhir.io/hapi-fhir/docs/](https://hapifhir.io/hapi-fhir/docs/)
- **FHIR Package Registry:** [https://packages.fhir.org/](https://packages.fhir.org/)

---

## Support

For issues related to:
- **OZO FHIR Package:** Create an issue on the [GitHub repository](https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/issues)
- **HAPI FHIR Server:** Consult the [HAPI FHIR documentation](https://hapifhir.io/) or community forums
- **Dutch NL-core Profiles:** Visit [Nictiz](https://www.nictiz.nl/) for support

---

## Summary

Installing the OZO FHIR Implementation Guide on a HAPI FHIR server enables:
- Validation of OZO-specific resources and profiles
- Support for NEN7510-compliant audit logging
- Integration with Dutch healthcare standards (NL-core)
- Authentication and authorization patterns for the OZO platform

By following this guide, you can ensure your HAPI FHIR server is properly configured to support OZO platform integrations.
