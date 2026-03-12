#!/bin/sh -eu

README=${1:-README.md}
START_MARKER='<!-- BEGIN AUTO-GENERATED VERSION USAGE -->'
END_MARKER='<!-- END AUTO-GENERATED VERSION USAGE -->'
VERSION=$(grep '^FROM rust:' official/Dockerfile | cut -f 2 -d ':' | cut -f 1 -d '-')
TMP=$(mktemp)

cleanup() {
    rm -f "$TMP"
}

trap cleanup EXIT INT TERM

awk \
    -v version="$VERSION" \
    -v start="$START_MARKER" \
    -v end="$END_MARKER" \
    '
    BEGIN {
        in_block = 0
        replaced = 0
        end_seen = 0
    }
    $0 == start {
        print
        print "Or specify a distribution and version:"
        print ""
        print "```bash"
        print "docker pull ghcr.io/yasuyuky/rust-ubuntu:jammy-" version
        print "```"
        print ""
        print "## Available Tags"
        print ""
        print "- `latest` - Latest Rust on Ubuntu Focal (20.04)"
        print "- `<VERSION>` - Specific Rust version on Focal (e.g., `" version "`)"
        print "- `<DIST>-<VERSION>` - Specific distribution and version (e.g., `jammy-" version "`, `noble-" version "`)"
        in_block = 1
        replaced = 1
        next
    }
    $0 == end {
        in_block = 0
        end_seen = 1
        print
        next
    }
    !in_block {
        print
    }
    END {
        if (!replaced) {
            exit 2
        }
        if (!end_seen) {
            exit 3
        }
    }
    ' "$README" > "$TMP"

mv "$TMP" "$README"
