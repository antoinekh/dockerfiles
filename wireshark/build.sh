#!/bin/bash
# Build and push the Wireshark (GUI-over-noVNC) image.
# Usage: ./build.sh [tag]     e.g. ./build.sh 4.6.6
# With no argument the tag is the latest stable Wireshark version read from the
# PPA, i.e. the exact version the image installs.
# Releases: https://www.wireshark.org/download.html
#
# Override the target image with IMAGE=..., e.g.
#   IMAGE=ghcr.io/me/wireshark ./build.sh
set -euo pipefail

# noble = the suite of the ubuntu-24.04 base image in wireshark.dockerfile.
ppa_packages="https://ppa.launchpadcontent.net/wireshark-dev/stable/ubuntu/dists/noble/main/binary-amd64/Packages.gz"

version=${1:-}
if [[ -z $version ]]; then
  version=$(curl -fsSL "$ppa_packages" | gunzip \
    | awk '/^Package: wireshark$/{p=1} p&&/^Version:/{v=$2; sub(/-.*/,"",v); print v; exit}')
fi
version=${version#v}
[[ -n $version ]] || { echo "could not resolve the Wireshark version from the PPA" >&2; exit 1; }
image=${IMAGE:-ghcr.io/antoinekh/wireshark}

docker buildx build \
  --push \
  --platform linux/amd64,linux/arm64 \
  -t "${image}:${version}" \
  -t "${image}:latest" \
  -f wireshark.dockerfile .
