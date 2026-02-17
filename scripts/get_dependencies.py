#!/usr/bin/env python3
"""Parse sushi-config.yaml and output dependency package@version lines for fhir install."""

import yaml
import sys

def get_dependencies(config_path="sushi-config.yaml"):
    with open(config_path, "r") as f:
        config = yaml.safe_load(f)

    dependencies = config.get("dependencies", {})
    for pkg, value in dependencies.items():
        if isinstance(value, dict):
            version = value.get("version", "")
        else:
            version = value
        if version:
            print(f"{pkg}@{version}")

if __name__ == "__main__":
    config_path = sys.argv[1] if len(sys.argv) > 1 else "sushi-config.yaml"
    get_dependencies(config_path)
