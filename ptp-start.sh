#!/bin/bash

# SPDX-FileCopyrightText: Copyright © 2022 Kebag-Logic
# SPDX-FileCopyrightText: Copyright © 2025 Alexandre Malki <alexandre.malki@kebag-logic.com>
# SPDX-FileCopyrightText: Copyright © 2025 Simon Gapp <simon.gapp@kebag-logic.com>
# SPDX-License-Identifier: MIT

# Part of the code taken from https://tsn.readthedocs.io/

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

trap kill_all SIGINT EXIT

# Keep NTP enabled. ptp4l disciplines the NIC PHC directly and PipeWire reads gPTP
# time from the PHC, so the system clock (CLOCK_REALTIME) stays independent and NTP
# can keep it on wall-clock time. phc2sys is no longer used.
sudo timedatectl set-ntp true

# Start ptp4l (disciplines the PHC; --step_threshold lets it step a large initial offset)
sudo ptp4l -i "$IFACE" -f ~/linuxptp/configs/gPTP.cfg --step_threshold=1 &
PTP_PID=$!
sudo chrt -f -p 53 "$PTP_PID"

# Set grandmaster settings (optional: skip if pmc is not installed)
if command -v pmc >/dev/null 2>&1; then
sudo pmc -u -b 0 -t 1 "SET GRANDMASTER_SETTINGS_NP clockClass 247 \
    clockAccuracy 0xfe offsetScaledLogVariance 0xffff \
    currentUtcOffset 37 leap61 0 leap59 0 currentUtcOffsetValid 1 \
    ptpTimescale 1 timeTraceable 1 frequencyTraceable 0 \
    timeSource 0xa0"
fi

# Wait for ptp4l
wait "$PTP_PID"
