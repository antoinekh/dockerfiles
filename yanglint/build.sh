#!/bin/bash
# Build and push the yanglint image for a given libyang release.
# Usage: ./build.sh <libyang-version>     e.g. ./build.sh 3.13.6
# Releases: https://github.com/CESNET/libyang/releases
#
# Override the target image with IMAGE=..., e.g.
#   IMAGE=ghcr.io/me/yanglint ./build.sh 3.13.6
set -euo pipefail

if [[ -z ${1:-} ]]; then
  echo "Usage: $0 <libyang-version>   e.g. 3.13.6" >&2
  exit 1
fi

version=${1#v}
image=${IMAGE:-ghcr.io/antoinekh/yanglint}

docker buildx build \
  --push \
  --platform linux/arm64,linux/amd64 \
  -t "${image}:${version}" \
  -t "${image}:latest" \
  --build-arg VERSION="${version}" \
  -f yanglint.dockerfile .
