#!/bin/bash

# SPDX-FileCopyrightText: Copyright © 2022 Kebag-Logic
# SPDX-FileCopyrightText: Copyright © 2025 Alexandre Malki <alexandre.malki@kebag-logic.com>
# SPDX-FileCopyrightText: Copyright © 2025 Simon Gapp <simon.gapp@kebag-logic.com>
# SPDX-License-Identifier: MIT

# Part of the code taken from https://tsn.readthedocs.io/
RT_PRIO="${RT_PRIO:-95}"                          # rtprio for ptp4l (PipeWire needs it too)

# Configuration
GPTP_CFG="${GPTP_CFG:-./gPTP.cfg}"   # --gptp-cfg


# Use AVB_INTERFACE from environment if no argument is passed
IFACE="${1:-$AVB_INTERFACE}"

if [ -z "$IFACE" ]; then
    echo "Usage: $0 [<network-interface>]"
    echo "Selected interface: (none)"
    echo "If no interface is printed, make sure that AVB_INTERFACE is set in your environment or .bashrc"
    exit 1
fi

echo "Selected interface: $IFACE"

function kill_all() {
    echo "Stopping PTP services..."
    sudo pkill ptp4l
}

# gPTP: ptp4l only. NTP owns CLOCK_REALTIME; ptp4l owns the NIC PHC. phc2sys would fight NTP.
start_gptp() {
    log "gPTP: ptp4l on ${IFACE} (no phc2sys; NTP owns REALTIME)"
    pkill -x phc2sys 2>/dev/null || true
    pkill -x ptp4l   2>/dev/null || true
    sleep 1
    setsid "$PTP4L_BIN" -f "$GPTP_CFG" -i "$IFACE" -m >"$PTP4L_LOG" 2>&1 </dev/null &
    sleep 4
    log "  ptp4l: $(tail -n1 "$PTP4L_LOG" | grep -oE 'rms +[0-9]+|to SLAVE|grand master' || echo '(starting)')"
}


function raise_rt_limits() {
    ulimit -r "$RT_PRIO" 2>/dev/null || warn "could not set rtprio $RT_PRIO"
    ulimit -l unlimited  2>/dev/null || true
}


trap kill_all SIGINT EXIT

raise_rt_limits
# Start ptp4l (disciplines the PHC; --step_threshold lets it step a large initial offset)
sudo ptp4l -i "$IFACE" -f ./gPTP.cfg --step_threshold=1 &
PTP_PID=$!


# Wait for ptp4l
wait "$PTP_PID"
