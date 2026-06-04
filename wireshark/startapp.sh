#!/bin/bash
# Entry point invoked by the jlesage baseimage-gui supervisor.
# Default to /pcaps (created in the image) for saved captures, but never let
# this step fail the service: the base image tears the whole container down if
# the app exits non-zero, which would loop the capture window. With
# PACKETFLIX_LINK set, launch straight onto that remote capture via the
# cshargextcap packetflix extcap; otherwise start Wireshark idle.

cd /pcaps 2>/dev/null || true

if [[ -n ${PACKETFLIX_LINK:-} ]]; then
  exec /usr/bin/wireshark -k -i packetflix -o "extcap.packetflix.url:${PACKETFLIX_LINK}"
else
  exec /usr/bin/wireshark
fi
