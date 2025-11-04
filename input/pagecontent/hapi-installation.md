# Installing OZO FHIR Package in HAPI FHIR Server

This manual provides step-by-step instructions for installing the OZO FHIR Implementation Guide package in a HAPI FHIR server.

## Overview

The OZO FHIR Implementation Guide is distributed as a packaged release that can be installed on HAPI FHIR servers to enable validation and support for OZO-specific profiles, extensions, and resources.

## Prerequisites

- HAPI FHIR Server (version compatible with FHIR R4)
- Java 11 or higher
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
- **Latest Release:** [v0.1.0](https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/releases/tag/v0.1.0)

From the release page, copy the URL of the `.tgz` package file. For version 0.1.0, the package is:
```
fhir.ozo-0.1.0.tgz
```

The full download URL will be:
```
https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/releases/download/v0.1.0/fhir.ozo-0.1.0.tgz
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

    # Disable validation during package installation to bypass snapshot generation issues
    iginstaller_validationenabled: false

    # Flag filters resources during package installation
    validate_resource_status_for_package_upload: false

    implementationguides:
      ozo:
        name: fhir.ozo
        version: 0.1.0
        packageUrl: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/releases/download/v0.1.0/fhir.ozo-0.1.0.tgz
        fetchDependencies: true
        installMode: STORE_AND_INSTALL
```

#### Configuration Parameters Explained

| Parameter | Description | Recommended Value |
|-----------|-------------|-------------------|
| **name** | The package identifier (must match the package ID) | `fhir.ozo` |
| **version** | The version of the package to install | `0.1.0` |
| **packageUrl** | Direct URL to the `.tgz` package file | Release download URL |
| **fetchDependencies** | Whether to automatically fetch and install dependencies (NL-core profiles, etc.) | `true` |
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
```

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
INFO: Installing package fhir.ozo version 0.1.0
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

---

## Creating Resources with OZO Profiles

After installing the OZO package, you can create FHIR resources that conform to OZO profiles. To ensure proper validation, you must set the `meta.profile` element to the canonical URL of the OZO profile.

### Example: Creating an OZO CareTeam Resource

The OZO CareTeam profile has the following canonical URL:
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
| **OZOAuditEvent** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOAuditEvent` |
| **OZOPatient** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPatient` |
| **OZOPractitioner** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOPractitioner` |
| **OZORelatedPerson** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZORelatedPerson` |
| **OZOOrganization** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOOrganization` |
| **OZOCommunication** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOCommunication` |
| **OZOTask** | `http://ozoverbindzorg.nl/fhir/StructureDefinition/OZOTask` |

### Important Notes

1. **Always set meta.profile**: The `meta.profile` element tells the HAPI FHIR server which profile to validate against.

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
wget https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/releases/download/v0.1.0/fhir.ozo-0.1.0.tgz
```

### Step 2: Upload via FHIR API

Use the `$install` operation to upload the package:

```bash
curl -X POST \
  -H "Content-Type: application/gzip" \
  --data-binary @fhir.ozo-0.1.0.tgz \
  "http://localhost:8080/fhir/ImplementationGuide/\$install"
```

### Step 3: Verify Installation

Follow the same verification steps as in Method 1.

---

## Package Dependencies

The OZO FHIR Implementation Guide depends on the following packages, which will be automatically installed if `fetchDependencies: true` is configured:

| Package                       | Version       | Description                                    |
|-------------------------------|---------------|------------------------------------------------|
| **nictiz.fhir.nl.r4.zib2020** | 0.12.0-beta.4 | Dutch Health and Care Information models (ZIB) |
| **nictiz.fhir.nl.r4.nl-core** | 0.12.0-beta.4 | Dutch national core profiles                   |

These dependencies are required for proper validation of Dutch healthcare resources used in the OZO platform.

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

### Issue: Dependencies Not Installed

**Solution:** Verify that `fetchDependencies: true` is set in the implementation guide configuration. You may also need to ensure the server has internet access to download dependencies from package registries.

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
       version: 0.2.0  # New version
       packageUrl: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/releases/download/v0.2.0/fhir.ozo-0.2.0.tgz
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

    # Enable repository validation
    enable_repository_validating_interceptor: true

    # Disable validation during IG installation
    iginstaller_validationenabled: false
    validate_resource_status_for_package_upload: false

    # Implementation Guides
    implementationguides:
      # OZO FHIR Implementation Guide
      ozo:
        name: fhir.ozo
        version: 0.1.0
        packageUrl: https://github.com/ozoverbindzorg/integrale-netwerk-communicatie/releases/download/v0.1.0/fhir.ozo-0.1.0.tgz
        fetchDependencies: true
        installMode: STORE_AND_INSTALL

      # Example: Other implementation guides can be added here
      # koppeltaal:
      #   name: koppeltaalv2.00
      #   version: 0.15.0-beta.9
      #   packageUrl: https://github.com/vzvznl/Koppeltaal-2.0-FHIR/releases/download/v0.15.0-beta.9/koppeltaalv2-0.15.0-beta.9.tgz
      #   fetchDependencies: true
      #   installMode: STORE_AND_INSTALL

    # Supported resource types (ensure OZO resources are included)
    supported_resource_types:
      - AuditEvent
      - CareTeam
      - Communication
      - CommunicationRequest
      - Organization
      - Patient
      - Practitioner
      - RelatedPerson
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
