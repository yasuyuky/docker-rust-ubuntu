#!/bin/sh -eux

VERSION=$(grep rust Dockerfile.official | cut -f 2 -d ':' | cut -f 1 -d '-')
sed "s/%%RUST_VERSION%%/${VERSION}/g" Dockerfile.template >Dockerfile
echo ::set-output name=version::${VERSION}
