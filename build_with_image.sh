#!/bin/bash
# Quick build script using pre-built Docker image

set -e

echo "Building OZO Implementation Guide using Docker..."

# Configuration
IMAGE_NAME=${IMAGE_NAME:-registry.gitlab.com/headease/ozo-refererence-impl/ozo-implementation-guide/main:latest}

# Pull latest image
echo "Pulling Docker image: $IMAGE_NAME"
docker pull "$IMAGE_NAME"

# Create output directories
mkdir -p ./public ./output

# Run the build
echo "Running build in Docker container..."
docker run --rm -v "${PWD}:/src" "$IMAGE_NAME"

echo ""
echo "Build complete!"
echo "Opening Implementation Guide in browser..."
open public/index.html || xdg-open public/index.html || echo "Please open public/index.html manually"
