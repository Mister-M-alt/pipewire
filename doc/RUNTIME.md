# PipeWire Milan-AVB Runtime Guide

## Scope

This document describes how to start and operate the PipeWire Milan-AVB environment after installation.

---

## Recommended network topology

- Use a star topology as recommended for Ethernet networks.
- Make sure to use AVB capable switches. A variety of Milan-AVB certified switches can be found in the [Avnu Certified Product Registry](https://avnu.org/certified-product-registry/?type=Switch)

### Dedicated network interface recommendation

Please refer to the [Network Interfaces section.](../README.md#network-interfaces)

---

## Start time synchronization

The PTP instance needs to run in a
separate terminal as follows:

### Start LinuxPTP

> [!IMPORTANT]
> Keep this terminal running while using Milan-AVB.
> The gPTP synchronization services must remain active during operation.

> [!NOTE]
> ptp4l disciplines the NIC PHC directly and PipeWire reads gPTP time from the PHC.
> phc2sys is not used, and NTP is left enabled on the system clock.

```bash
cd ~/pipewire
./ptp-start.sh
Selected interface: enp2s0
sending: SET GRANDMASTER_SETTINGS_NP
ptp4l[2050.269]: rms 37030500695 max 37030515520 freq  -0 +/-   0 delay  2174 +/-   0
ptp4l[2051.269]: rms       12 max       34 freq -26000 +/- 102 delay  2164 +/-  12
ptp4l[2052.269]: rms        4 max        9 freq -26010 +/-  45 delay  2160 +/-  10
ptp4l[2053.269]: rms        2 max        5 freq -26005 +/-  18 delay  2158 +/-   8
```

---

## Start PipeWire Milan-AVB
Once PipeWire is installed, it can be started as follows:

`cd ~/pipewire`
Then execute
`./start_pipewire.sh`

---

## Configure audio routing

### Install qpwgraph

1. Install qpwgraph

    `sudo pacman -S qpwgraph`

2. Run qpwgraph by typing `qpwgraph` into the terminal. A window with the available Milan-AVB sources and sinks should show up. You can route audio from other applications to pipewire-milan-avb.

---

## Configure Milan stream connections

### Install Hive

1. Download and install Hive from [https://github.com/christophe-calmejane/Hive/releases](https://github.com/christophe-calmejane/Hive/releases)
2. Run Hive and connect the Milan-AVB device to the Pipewire instance
