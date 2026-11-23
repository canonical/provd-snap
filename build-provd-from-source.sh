#!/bin/bash
# Build the provd daemon binary from its source repository and install
# it as ./provd-src-built, which the 'provd' part's override-build
# stages in place of the resolute deb's binary (skipping the deb's md5
# archive-identity gate - see snapcraft.yaml's override-build).
#
# The pin is the reviewable provenance for the packed binary: the
# defaults name the integration branch carrying the provd fixes the
# desktop/26 image flow depends on (the wizard a11y handover writer and
# the Accounts DeleteUser rollback signature fix) until their upstream
# PRs merge, after which the defaults flip to
# canonical/ubuntu-desktop-provision@main. Override with
# PROVD_SOURCE_REPO / PROVD_SOURCE_REF / PROVD_SOURCE_COMMIT.
#
# Writes ./provd-src-built.provenance (repo, ref, resolved commit, go
# version, build time) next to the binary; the packed snap's version
# string (0.1.5+t26handover) marks the source-built path.
set -euo pipefail

REPO="${PROVD_SOURCE_REPO:-https://github.com/chris-bainbridge/ubuntu-desktop-provision}"
REF="${PROVD_SOURCE_REF:-core26-provd}"
COMMIT="${PROVD_SOURCE_COMMIT:-}"

root="$PWD"
tmp="$(mktemp -d "$root/provd-src.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

git clone --quiet --depth 1 --branch "$REF" "$REPO" "$tmp/src"
if [ -n "$COMMIT" ]; then
    git -C "$tmp/src" fetch --quiet --depth 1 origin "$COMMIT"
    git -C "$tmp/src" checkout --quiet --detach "$COMMIT"
fi
resolved="$(git -C "$tmp/src" rev-parse HEAD)"

(cd "$tmp/src/provd" && go build -o "$root/provd-src-built" ./cmd/provd)

cat > "$root/provd-src-built.provenance" <<EOF
repo: $REPO
ref: $REF
commit: $resolved
go: $(go version)
built: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

echo "provd built from $REPO@$resolved (ref $REF)"
