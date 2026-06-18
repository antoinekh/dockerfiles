# raven-bgp-routing-security-monitor

Container image for [RAVEN](https://github.com/nokia/bgp-routing-security-monitor) (Nokia `bgp-routing-security-monitor`), a single-binary BGP routing security monitor: BMP + RPKI ROV + ASPA path validation, with a Prometheus exporter and an events/webhook engine. The `raven` binary is built from source for a chosen git ref.

## Image

`ghcr.io/antoinekh/raven-bgp-routing-security-monitor`, multi-arch (amd64 / arm64):

- `:latest` and `:<short-commit>` track the tip of upstream `main`.
- `:<version>` (e.g. `:0.3.2`) is built from the matching release tag.

## Usage

The entrypoint is `raven`, so pass normal raven subcommands. Mount your config and expose the BMP / API / metrics ports your config declares.

```bash
docker run --rm -v "$PWD/raven.yaml":/etc/raven/raven.yaml:ro \
  -p 11019:11019 -p 11020:11020 -p 9595:9595 \
  ghcr.io/antoinekh/raven-bgp-routing-security-monitor:latest serve --config /etc/raven/raven.yaml
```

## Build locally

```bash
# build + push :<tag> and :latest (multi-arch)
./build.sh v0.3.2     # a release tag -> :0.3.2 and :latest
./build.sh main       # tip of main   -> :main and :latest

# or just build one arch locally, no push:
docker build -f raven-bgp-routing-security-monitor.dockerfile --build-arg REF=v0.3.2 -t raven-bgp-routing-security-monitor .
```

Pick a ref from <https://github.com/nokia/bgp-routing-security-monitor> (branch `main` for the latest commit, or a `vX.Y.Z` release tag).
