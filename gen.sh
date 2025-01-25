#!/bin/sh -eux
GITHUB_OUTPUT=${GITHUB_OUTPUT:-/dev/null}
VERSION=${VERSION:-$(grep FROM official/Dockerfile | cut -f 2 -d ':' | cut -f 1 -d '-')}
sed "s/%%RUST_VERSION%%/${VERSION}/g" Dockerfile.template >Dockerfile
echo version=${VERSION} >>$GITHUB_OUTPUT
