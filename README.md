# yasuyuky/rust-ubuntu

Build image for Rust based on Ubuntu

With the following additional utilities:

- [wild](https://github.com/davidlattimore/wild) - A very fast linker for Linux
- [sccache](https://github.com/mozilla/sccache) - Shared compilation cache
- [cargo-deb](https://github.com/kornelski/cargo-deb) - Debian package generator

## Features

- **Multi-architecture support**: `linux/amd64`, `linux/arm64`, `linux/arm/v7`
- **Multi-stage build**: Efficient Docker image using BuildKit
- **Multiple Ubuntu versions**: `focal` (20.04), `jammy` (22.04), `noble` (24.04)
- **Automatic updates**: Dependabot monitors Rust version updates

## Quick Start

Pull the latest image:

```bash
docker pull ghcr.io/yasuyuky/rust-ubuntu:latest
```

Or specify a distribution and version:

```bash
docker pull ghcr.io/yasuyuky/rust-ubuntu:jammy-1.92.0
```

## Available Tags

- `latest` - Latest Rust on Ubuntu Focal (20.04)
- `<VERSION>` - Specific Rust version on Focal (e.g., `1.92.0`)
- `<DIST>-<VERSION>` - Specific distribution and version (e.g., `jammy-1.92.0`, `noble-1.92.0`)

## Building Locally

### Using the new multi-stage build (Recommended)

```bash
# Build for current architecture
./build-multistage.sh jammy amd64

# Build for ARM64
./build-multistage.sh noble arm64
```

### Using the legacy template-based build

```bash
# Generate Dockerfile
./gen.sh Dockerfile.template

# Build
./build.sh jammy
```

## CI/CD

The repository uses GitHub Actions to automatically build and push multi-architecture images:

- **Version extraction**: Reads Rust version from `official/Dockerfile`
- **Parallel builds**: Builds all distributions and architectures in parallel using native runners
- **Manifest creation**: Combines platform-specific images into multi-arch manifests

See `.github/workflows/release-multistage.yml` for details.
