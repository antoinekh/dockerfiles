# yanglint (CESNET/libyang) container image.
#
# Builds a chosen libyang release from source and ships just `yanglint` plus the
# libyang runtime libraries on a slim Debian base. Building from source (instead
# of installing the distro's libyang3/libyang-tools packages by name) keeps this
# version-agnostic: the same Dockerfile works across libyang 3.x / 4.x / 5.x,
# whose package names change with the SO/ABI major.
#
# VERSION is a libyang release WITHOUT the leading "v" (the git tag is v<VERSION>):
#   https://github.com/CESNET/libyang/releases       e.g. 3.13.6
#
#   docker build -f yanglint.dockerfile --build-arg VERSION=3.13.6 -t yanglint .

# ---- build stage ----------------------------------------------------------
FROM debian:bookworm-slim AS build

ARG VERSION=3.13.6

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates git cmake build-essential pkg-config libpcre2-dev \
 && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "v${VERSION}" \
      https://github.com/CESNET/libyang.git /src \
 && cmake -S /src -B /build -DCMAKE_BUILD_TYPE=Release -DENABLE_TESTS=OFF \
 && cmake --build /build -j "$(nproc)" \
 && cmake --install /build

# ---- runtime stage --------------------------------------------------------
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      libpcre2-8-0 \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bin/yanglint /usr/local/bin/yanglint
COPY --from=build /usr/local/lib/ /usr/local/lib/
RUN ldconfig

WORKDIR /work
ENTRYPOINT ["yanglint"]
