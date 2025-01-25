#!/bin/sh -eux

# Default to focal if no distribution specified
DIST=${1:-focal}
VALID_DISTS="focal jammy noble"

# Validate distribution
if ! echo "$VALID_DISTS" | grep -w "$DIST" >/dev/null; then
    echo "Error: Invalid distribution. Please use one of: $VALID_DISTS"
    exit 1
fi

# Generate Dockerfile from template
./gen.sh Dockerfile.template

# Get version for tagging
VERSION=$(grep RUST_VERSION= Dockerfile | cut -d'=' -f2)

# Build base image
echo "Building base image..."
docker buildx build \
    --platform linux/$(uname -m) \
    --build-arg "dist=$DIST" \
    --tag "rust-ubuntu:$DIST-$VERSION" \
    --load \
    .

# Create directories for tool building
PLATFORM=linux/$(uname -m)
mkdir -p target/${PLATFORM##*/}
mkdir -p ${PLATFORM}

# Build cargo-deb
echo "Building cargo-deb..."
docker run \
    -v "$(pwd)/target/${PLATFORM##*/}:/work" \
    "rust-ubuntu:$DIST-$VERSION" \
    cargo install --target-dir=/work cargo-deb
cp "target/${PLATFORM##*/}/release/cargo-deb" "${PLATFORM}/"

# Build sccache
echo "Building sccache..."
docker run \
    -v "$(pwd)/target/${PLATFORM##*/}:/work" \
    "rust-ubuntu:$DIST-$VERSION" \
    cargo install --target-dir=/work sccache
cp "target/${PLATFORM##*/}/release/sccache" "${PLATFORM}/"

# Build final image with tools
echo "Building final image with tools..."
docker buildx build \
    --platform ${PLATFORM} \
    --build-arg "TARGETPLATFORM=${PLATFORM}" \
    --build-arg "dist=${DIST}" \
    --build-arg "ver=${VERSION}" \
    --tag "rust-ubuntu:$DIST-$VERSION-tools" \
    --load \
    tools/

echo "Successfully built images:"
echo "- rust-ubuntu:$DIST-$VERSION (base image)"
echo "- rust-ubuntu:$DIST-$VERSION-tools (image with cargo-deb and sccache)"
echo ""
echo "You can run them with:"
echo "docker run -it rust-ubuntu:$DIST-$VERSION"
echo "docker run -it rust-ubuntu:$DIST-$VERSION-tools"
