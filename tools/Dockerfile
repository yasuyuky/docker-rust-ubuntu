ARG dist
ARG ver
FROM ghcr.io/yasuyuky/rust-ubuntu:${dist}-${ver}
ARG TARGETPLATFORM

COPY $TARGETPLATFORM/sccache /usr/local/cargo/bin/sccache
COPY $TARGETPLATFORM/cargo-deb /usr/local/cargo/bin/cargo-deb
