# Wireshark in a browser: the latest stable Wireshark (Qt6 GUI) served over
# noVNC, plus the Siemens cshargextcap "packetflix" extcap for remote capture
# (e.g. the containerlab VS Code extension / Edgeshark). Built on
# jlesage/baseimage-gui; Wireshark comes from the official stable PPA, which only
# ever ships the latest stable release. GUI: http://<host>:5800 (web) or
# vnc://<host>:5900. Set PACKETFLIX_LINK to auto-start a remote capture.
#
#   docker build -f wireshark.dockerfile -t wireshark .

FROM jlesage/baseimage-gui:ubuntu-24.04-v4

ENV APP_NAME="Wireshark"

# Make noVNC track the browser window size instead of a fixed resolution.
RUN if [ -f /opt/noVNC/app/ui.js ]; then \
      sed -i "s/UI.initSetting('resize', resize);/UI.initSetting('resize', 'remote');/g" /opt/noVNC/app/ui.js; \
    fi

# Wireshark (Qt6 GUI) + tshark from the official stable PPA, plus the Siemens
# cshargextcap packetflix extcap. Notes:
#  - add-pkg is the base's package helper: it provisions the user/group database
#    that Debian postinst scripts need at build time (the base only creates it
#    at runtime) and trims the apt cache afterwards.
#  - The PPA is added by hand; software-properties-common would pull in systemd,
#    which fails to configure on this base.
#  - cshargextcap's .deb installs under /usr/lib/<triplet>/wireshark/extcap, but
#    Wireshark 4.6 only scans /usr/libexec/wireshark/extcap, so it is symlinked
#    there or the packetflix interface is never discovered.
#  - /pcaps is the default capture/save dir, world-writable so the non-root app
#    user can use it (capture integrations such as containerlab bind-mount it).
RUN add-pkg ca-certificates curl jq \
 && key=/etc/apt/keyrings/wireshark-dev.asc \
 && fp="$(curl -fsSL https://api.launchpad.net/devel/~wireshark-dev/+archive/ubuntu/stable | jq -r .signing_key_fingerprint)" \
 && curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x$fp" -o "$key" \
 && . /etc/os-release \
 && echo "deb [signed-by=$key] https://ppa.launchpadcontent.net/wireshark-dev/stable/ubuntu $VERSION_CODENAME main" \
      > /etc/apt/sources.list.d/wireshark-dev.list \
 && add-pkg wireshark tshark \
 && cstag="$(curl -fsSL https://api.github.com/repos/siemens/cshargextcap/releases/latest | jq -r .tag_name)" \
 && curl -fsSL -o /tmp/cshargextcap.deb \
      "https://github.com/siemens/cshargextcap/releases/download/$cstag/cshargextcap_${cstag#v}_linux_$(dpkg --print-architecture).deb" \
 && add-pkg /tmp/cshargextcap.deb \
 && rm -f /tmp/cshargextcap.deb \
 && ln -sf /usr/lib/*/wireshark/extcap/cshargextcap /usr/libexec/wireshark/extcap/cshargextcap \
 && install -d -m 777 /pcaps

COPY --chmod=755 startapp.sh /startapp.sh
