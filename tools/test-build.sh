#!/bin/sh -eux

# Usage: ./tools/test-build.sh [DIST] [ARCH]
# Example: ./tools/test-build.sh jammy amd64

DIST=${1:-jammy}
ARCH=${2:-amd64}
VERSION=$(grep FROM official/Dockerfile | cut -f 2 -d ':' | cut -f 1 -d '-')
IMAGE_NAME="ghcr.io/yasuyuky/rust-ubuntu:${DIST}-${VERSION}"
PLATFORM="linux/${ARCH}"

echo "Building ${IMAGE_NAME} for ${PLATFORM}"

docker buildx build \
    --platform "${PLATFORM}" \
    --build-arg DIST="${DIST}" \
    --build-arg RUST_VERSION="${VERSION}" \
    --file Dockerfile.multistage \
    --tag "${IMAGE_NAME}" \
    --load \
    .

run_in_image() {
    docker run --rm --platform "${PLATFORM}" "${IMAGE_NAME}" "$@"
}

build_hello_world() {
    docker run --rm --platform "${PLATFORM}" "${IMAGE_NAME}" sh -euxc '
        tmp=$(mktemp -d);
        cd "$tmp";
        cargo new hello-wild --bin;
        cd hello-wild;
        echo "fn main() { println!(\"hello wild\"); }" > src/main.rs;
        cargo build --release;
        ./target/release/hello-wild;
    '
}

run_in_image rustc --version
run_in_image cargo --version
run_in_image sccache --version
run_in_image cargo-deb --version

if [ "${ARCH}" != "arm" ]; then
    run_in_image wild --version
else
    run_in_image wild
fi

build_hello_world

echo "Build and sanity checks passed for ${IMAGE_NAME} (${PLATFORM})"
