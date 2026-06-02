#!/bin/bash

# SPDX-FileCopyrightText: Copyright © 2025 Alexandre Malki <alexandre.malki@kebag-logic.com>
# SPDX-License-Identifier: MIT

# Generic Milan-AVB bring-up. Run once per boot to configure the network
# interface (traffic shaper + VLAN), start gPTP, then start PipeWire Milan-AVB.
# Build/install once first with build-and-install.sh (see doc/INSTALL.md).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Interface from the first argument or the AVB_INTERFACE environment variable
IFACE="${1:-${AVB_INTERFACE:-}}"

if [ -z "$IFACE" ]; then
    echo "Usage: $0 [<network-interface>]"
    echo "Or set AVB_INTERFACE in your environment (see doc/INSTALL.md)."
    exit 1
fi
export AVB_INTERFACE="$IFACE"

echo "Bringing up Milan-AVB on $IFACE"

# 1. Traffic shaper (mqprio + CBS + ETF) and VLAN id 2
sudo "$SCRIPT_DIR/prepare-traffic-shaper.sh" "$IFACE"
sudo "$SCRIPT_DIR/setup-vlan.sh" "$IFACE"

# 2. gPTP time synchronization (background; log in /tmp/ptp-start.log)
"$SCRIPT_DIR/ptp-start.sh" "$IFACE" > /tmp/ptp-start.log 2>&1 &
echo "Started gPTP (ptp-start.sh), log: /tmp/ptp-start.log"

# 3. PipeWire Milan-AVB (foreground; Ctrl-C tears everything down)
"$SCRIPT_DIR/start_pipewire.sh"
