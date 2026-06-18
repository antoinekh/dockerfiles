# raven (Nokia bgp-routing-security-monitor) container image.
#
# Builds the `raven` binary from a chosen git ref of
# https://github.com/nokia/bgp-routing-security-monitor and ships the static
# binary on a slim alpine base. RAVEN is a single-binary BGP routing security
# monitor: BMP + RPKI ROV + ASPA path validation, with a Prometheus exporter
# and an events/webhook engine.
#
# REF is any branch or tag the upstream repo exposes:
#   - a branch (e.g. main)      -> the latest commit on that branch
#   - a release tag (e.g. v0.3.2)
#
#   docker build -f raven-bgp-routing-security-monitor.dockerfile \
#     --build-arg REF=v0.3.2 -t raven-bgp-routing-security-monitor .

# ---- build stage ----------------------------------------------------------
FROM golang:1.25-alpine AS build

ARG REF=main

RUN apk add --no-cache git

RUN git clone --depth 1 --branch "${REF}" \
      https://github.com/nokia/bgp-routing-security-monitor.git /src
WORKDIR /src
RUN CGO_ENABLED=0 go build -trimpath -o /raven ./cmd/raven

# ---- runtime stage --------------------------------------------------------
FROM alpine:latest

# ca-certificates so the events engine can reach HTTPS webhook endpoints.
RUN apk add --no-cache ca-certificates

COPY --from=build /raven /usr/local/bin/raven
ENTRYPOINT ["raven"]
