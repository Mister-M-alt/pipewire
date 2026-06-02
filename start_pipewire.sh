#!/bin/bash
# pipewire-avb is a CLIENT of a running PipeWire core, so make sure a core is up
# first, then start the Milan-AVB daemon.
if [ -z "$AVB_INTERFACE" ]; then
    echo "AVB_INTERFACE is not set"
    exit 1
fi

RUNTIME="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# (re)start the core PipeWire the AVB daemon attaches to
systemctl --user restart pipewire.service 2>/dev/null
sleep 1

# headless fallback: no user session -> start a plain core
if [ ! -S "$RUNTIME/pipewire-0" ]; then
    setsid -f /usr/bin/pipewire >/tmp/pipewire-core.log 2>&1
    sleep 2
fi

# clear any stale gPTP management socket from a previous run
rm -f /tmp/pipewire-avb-gptp-* 2>/dev/null

# start with verbose logging and the selected interface
/usr/bin/pipewire-avb -v
