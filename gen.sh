#!/bin/sh -eux
INPUT="$1"
OUTPUT="${1%.template}"
VERSION=$(grep FROM official/Dockerfile | cut -f 2 -d ':' | cut -f 1 -d '-')
sed "s/%%RUST_VERSION%%/${VERSION}/g" "$INPUT" > "$OUTPUT"
echo ::set-output name=version::${VERSION}
