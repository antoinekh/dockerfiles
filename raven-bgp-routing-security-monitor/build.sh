#!/bin/bash
# Build and push the raven-bgp-routing-security-monitor image for a given git ref.
# Usage: ./build.sh <ref>     e.g. ./build.sh v0.3.2   or   ./build.sh main
# Source: https://github.com/nokia/bgp-routing-security-monitor
#
# A release tag like v0.3.2 is published as :0.3.2 (leading "v" stripped); any
# other ref is published under its own name. :latest is always (re)pushed.
# Override the target image with IMAGE=..., e.g.
#   IMAGE=ghcr.io/me/raven-bgp-routing-security-monitor ./build.sh v0.3.2
set -euo pipefail

if [[ -z ${1:-} ]]; then
  echo "Usage: $0 <ref>   e.g. v0.3.2 or main" >&2
  exit 1
fi

ref=$1
tag=${ref#v}
image=${IMAGE:-ghcr.io/antoinekh/raven-bgp-routing-security-monitor}

docker buildx build \
  --push \
  --platform linux/arm64,linux/amd64 \
  -t "${image}:${tag}" \
  -t "${image}:latest" \
  --build-arg REF="${ref}" \
  -f raven-bgp-routing-security-monitor.dockerfile .
