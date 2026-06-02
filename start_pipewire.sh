#!/bin/bash
# pipewire-avb is a CLIENT of a running PipeWire core, so make sure a core is up
# AND its socket is ready before starting the Milan-AVB daemon (module-avb is
# mandatory and the daemon exits if the core isn't reachable yet).
if [ -z "$AVB_INTERFACE" ]; then
    echo "AVB_INTERFACE is not set"
    exit 1
fi

RUNTIME="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# headless nodes may have no logind session -> create the runtime dir
if [ ! -d "$RUNTIME" ]; then
    sudo mkdir -p "$RUNTIME" && sudo chown "$(id -u):$(id -g)" "$RUNTIME" && sudo chmod 700 "$RUNTIME"
fi

# (re)start the core PipeWire the AVB daemon attaches to
systemctl --user restart pipewire.service 2>/dev/null
# wait for the core socket; if it never appears, start a plain core and wait
for i in $(seq 1 8); do [ -S "$RUNTIME/pipewire-0" ] && break; sleep 1; done
if [ ! -S "$RUNTIME/pipewire-0" ]; then
    setsid -f /usr/bin/pipewire >/tmp/pipewire-core.log 2>&1
    for i in $(seq 1 15); do [ -S "$RUNTIME/pipewire-0" ] && break; sleep 1; done
fi

# clear any stale gPTP management socket from a previous run
rm -f /tmp/pipewire-avb-gptp-* 2>/dev/null

# start the Milan-AVB daemon with verbose logging and the selected interface
exec /usr/bin/pipewire-avb -v
