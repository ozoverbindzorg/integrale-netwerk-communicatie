#!/bin/bash
# Quick build script using pre-built Docker image

set -e

echo "Building OZO Implementation Guide using Docker..."

# Configuration
IMAGE_NAME=${IMAGE_NAME:-ozoverbindzorg/publisher:latest}

# Build the Docker image if it doesn't exist or if --build is passed
if [[ "$1" == "--build" ]] || ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
  echo "Building Docker image: $IMAGE_NAME"
  docker build -t "$IMAGE_NAME" .
else
  echo "Using existing Docker image: $IMAGE_NAME"
fi

# Create output directory
mkdir -p ./output

# Run the build
echo "Running build in Docker container..."
docker run --rm -v "${PWD}:/src" "$IMAGE_NAME"

echo ""
echo "Build complete!"
echo "Opening Implementation Guide in browser..."
open output/index.html || xdg-open output/index.html || echo "Please open output/index.html manually"
