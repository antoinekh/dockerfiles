# wireshark

Browser-accessible [Wireshark](https://www.wireshark.org/) GUI in a container, built on [`jlesage/baseimage-gui`](https://github.com/jlesage/docker-baseimage-gui). Wireshark comes from the official [`ppa:wireshark-dev/stable`](https://launchpad.net/~wireshark-dev/+archive/ubuntu/stable) PPA, so the image always ships the **latest stable Wireshark** (the distro package lags a release or two behind). It also bundles Siemens [`cshargextcap`](https://github.com/siemens/cshargextcap) for remote capture over a `packetflix://` link.

## Image

`ghcr.io/antoinekh/wireshark:<wireshark-version>` and `:latest`, multi-arch (amd64 / arm64).

## Usage

The GUI is served by the base image over a web page (noVNC) and plain VNC:

```bash
docker run --rm -p 5800:5800 -p 5900:5900 \
  -v "$PWD":/pcaps \
  ghcr.io/antoinekh/wireshark:latest
```

Then open <http://localhost:5800> (web) or connect a VNC client to `localhost:5900`. Files placed in the mounted `/pcaps` directory are visible from Wireshark's open/save dialogs.

To launch straight onto a remote capture, pass a packetflix link:

```bash
docker run --rm -p 5800:5800 \
  -e PACKETFLIX_LINK="packetflix:ws://device.example/capture?..." \
  ghcr.io/antoinekh/wireshark:latest
```

To capture from the host's own interfaces instead, share the host network and grant capture capabilities:

```bash
docker run --rm -p 5800:5800 \
  --network host --cap-add NET_ADMIN --cap-add NET_RAW \
  ghcr.io/antoinekh/wireshark:latest
```

## Build locally

```bash
# build + push :<version> and :latest (multi-arch); version read from the PPA
./build.sh

# or tag with an explicit version
./build.sh 4.6.6

# or just build one arch locally, no push:
docker build -f wireshark.dockerfile -t wireshark .
```

The image is not version-pinned: the `ppa:wireshark-dev/stable` PPA only ever carries the latest stable Wireshark, so every build installs that. `build.sh` reads the version back from the PPA to tag the image, so `:<version>` matches what is inside. See <https://www.wireshark.org/download.html>.
