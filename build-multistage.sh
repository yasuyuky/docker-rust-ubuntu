#!/bin/sh -eux

# Usage: ./build-multistage.sh [DIST] [ARCH]
# Example: ./build-multistage.sh jammy arm64

DIST=${1:-jammy}
ARCH=${2:-amd64}
VERSION=$(grep FROM official/Dockerfile | cut -f 2 -d ':' | cut -f 1 -d '-')
IMAGE_NAME="ghcr.io/yasuyuky/rust-ubuntu:${DIST}-${VERSION}"

echo "Building ${IMAGE_NAME} for linux/${ARCH}"

# Build with Docker Buildx for multi-architecture support
docker buildx build \
    --platform "linux/${ARCH}" \
    --build-arg DIST="${DIST}" \
    --build-arg RUST_VERSION="${VERSION}" \
    --file Dockerfile.multistage \
    --tag "${IMAGE_NAME}" \
    --load \
    .

# Verify the build
docker run --rm --platform "linux/${ARCH}" "${IMAGE_NAME}" rustc --version
docker run --rm --platform "linux/${ARCH}" "${IMAGE_NAME}" cargo --version
docker run --rm --platform "linux/${ARCH}" "${IMAGE_NAME}" sccache --version
docker run --rm --platform "linux/${ARCH}" "${IMAGE_NAME}" cargo-deb --version

echo "Build successful: ${IMAGE_NAME}"
