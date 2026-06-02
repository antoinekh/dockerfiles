# yanglint

Container image with [`yanglint`](https://github.com/CESNET/libyang) (CESNET libyang) for validating YANG schemas and instance data, built from source for a chosen libyang release.

## Image

`ghcr.io/antoinekh/yanglint:<libyang-version>` and `:latest`, multi-arch (amd64 / arm64).

## Usage

The entrypoint is `yanglint`, so pass normal yanglint arguments. Mount your model dir and data dir; `-p` recurses into subdirectories.

```bash
# validate an instance file (XML/JSON) against a model tree
docker run --rm -v "$PWD":/work ghcr.io/antoinekh/yanglint:latest \
  -p yang/ -t config yang/model.yang data.xml

# render a model as a tree
docker run --rm -v "$PWD":/work ghcr.io/antoinekh/yanglint:latest \
  -p yang/ -f tree yang/model.yang
```

## Build locally

```bash
# build + push :<version> and :latest (multi-arch)
./build.sh 3.13.6

# or just build one arch locally, no push:
docker build -f yanglint.dockerfile --build-arg VERSION=3.13.6 -t yanglint .
```

Pick a version from <https://github.com/CESNET/libyang/releases>. `v3.13.6` is a good default (latest 3.x, includes yanglint `extension-instance` data validation); `5.x` adds improved extension / OpenConfig handling.
