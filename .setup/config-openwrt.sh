#!/bin/sh
# ssh root@192.168.1.1 "PASSWD=? NYAAKEY=? KITTIESKEY=? sh -s" < config-openwrt.sh
set -e

# CHECK HOST
if [ "OpenWrt" != "$HOSTNAME" ] && [ "nyaa-link" != "$HOSTNAME" ]; then
  echo 'Hostname not OpenWrt or nyaa-link.'
  echo 'Exitting to prevent unintended damage to host...'
  exit 2
fi

# REQUIRED ENVIRONMENT VARIABLES
# PASSWD - router passwd
# NYAAKEY - nyaa-wifi key
# KITTIESKEY - kitties key

if [ -z "$PASSWD" ]; then
  echo 'PASSWD not defined, exitting...'
  exit 1
fi

if [ -z "$NYAAKEY" ]; then
  echo 'NYAAKEY not defined, exitting...'
  exit 1
fi

if [ -z "$KITTIESKEY" ]; then
  echo 'KITTIESKEY not defined, exitting...'
  exit 1
fi

# === Update root password ====================
# Ask for manual password input until passwd returns
# a success. The sleep is to enable Ctrl-C to exit.
echo 'Updating root password'
passwd <<EOF
$PASSWD
$PASSWD
EOF

# === Update hostname =========================
HOSTNAME="nyaa-link"
echo 'Setting hostname to' $HOSTNAME
uci set system.@system[0].hostname="$HOSTNAME"
uci commit system

# === Update the software packages ============
# Download and update all the interesting packages
# Some of these are pre-installed, but there is no harm in
# updating/installing them a second time.
echo 'Updating software packages'
{
  opkg update             # retrieve updated packages
  opkg install luci       # install the web GUI
  opkg install luci-ssl   # install the web GUI ssl
  opkg install tmux
  opkg install vim
} > /dev/null

# === Set the Time Zone =======================
TIMEZONE='CET-1CEST,M3.5.0,M10.5.0/3'
ZONENAME='Europe/Amsterdam'
echo 'Setting timezone to' $TIMEZONE
uci set system.@system[0].timezone="$TIMEZONE"
echo 'Setting zone name to' $ZONENAME
uci set system.@system[0].zonename="$ZONENAME"
uci commit system

# === Update WiFi info for the access point ===
# 1) Setup the interfaces
#   a) Delete default interfaces
#   b) Create new interfaces
#   c) Assign the options
#   d) AP specific options
#   e) Assign the ssid and encryption
# 2) Setup the radios
#   a) Assign the country
#   b) Enable

# To see all the wireless info:
#	uci show/export wireless
#
# Default interface indices and SSIDs are:
#	0 - nyaa-wifi5
#	1 - nyaa-wifi
#	2 - kitties5
#	3 - kitties

# === 1) Setup the interfaces =================
echo 'Setting up the wireless interfaces'

# === 1a) Delete default interfaces ===========
echo 'Deleting default radios'
uci delete wireless.default_radio0 > /dev/null 2>&1 || true
uci delete wireless.default_radio1 > /dev/null 2>&1 || true

# === 1b) Create new interfaces ===============
echo 'Creating the interfaces'
uci set wireless.nyaa_wifi5="wifi-iface"
uci set wireless.nyaa_wifi="wifi-iface"
uci set wireless.kitties5="wifi-iface"
uci set wireless.kitties="wifi-iface"

# === 1c) Assign the options ==================
echo 'Assigning some options'
uci set wireless.nyaa_wifi5.mode="ap"
uci set wireless.nyaa_wifi.mode="ap"
uci set wireless.kitties5.mode="ap"
uci set wireless.kitties.mode="ap"

uci set wireless.nyaa_wifi5.network="lan"
uci set wireless.nyaa_wifi.network="lan"
uci set wireless.kitties5.network="lan"
uci set wireless.kitties.network="lan"

# === 1d) AP specific options =================
echo 'Assigning ap specific options'
uci set wireless.nyaa_wifi5.hidden="1"
uci set wireless.nyaa_wifi.hidden="1"
uci set wireless.kitties5.hidden="0"
uci set wireless.kitties.hidden="0"

uci set wireless.nyaa_wifi5.device="radio0"
uci set wireless.nyaa_wifi.device="radio1"
uci set wireless.kitties5.device="radio0"
uci set wireless.kitties.device="radio1"

# === 1e) Assign the ssid and encryption ======

uci set wireless.nyaa_wifi5.ssid="nyaa-wifi5"
uci set wireless.nyaa_wifi.ssid="nyaa-wifi"
uci set wireless.kitties5.ssid="kitties5"
uci set wireless.kitties.ssid="kitties"

WI_ENC="psk2+ccmp"

uci set wireless.nyaa_wifi5.encryption=$WI_ENC
uci set wireless.nyaa_wifi.encryption=$WI_ENC
uci set wireless.kitties5.encryption=$WI_ENC
uci set wireless.kitties.encryption=$WI_ENC

uci set wireless.nyaa_wifi5.key=$NYAAKEY
uci set wireless.nyaa_wifi.key=$NYAAKEY
uci set wireless.kitties5.key=$KITTIESKEY
uci set wireless.kitties.key=$KITTIESKEY

# === 2) Setup the radios =====================
echo 'Setting up and enabling the radios'

# === 2a) Assign the country ==================
uci set wireless.radio0.country="NL"
uci set wireless.radio1.country="NL"

# === 2b) Enable ==============================
uci set wireless.radio0.disabled="0"
uci set wireless.radio1.disabled="0"

# === Commit Wireless  ========================
uci commit wireless

# === Configuring dropbear
authorized_key_core="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPbS2YTvSfdJgbOtSCrX/bwD3Ns1/Zq/C5h6bruJnKOVfLtoxxxxzzhiO3ufYGQP3sSUkVUJHtPh/hUQjaYJfOVKAYC4zBBoVv3P+HZ2gwwXJap4IG26/+Ckwb9woMoPKOMCVTEqbZ97c+H/QVlltCxJWb4uxWanNkV57A1wx8n0s1VWZJBdzOcvs1PhtrRMYW72YGT3V+T6adQSc9Ocqr+x5KqRZjbyDukF2frUheMHUjcaeeK9x0vSSDcohip2rRC3Y5Zs8TH3i2pw4bVRQHuo/y37x2mXnt4rlAKuJRUkc/Xt6yrXIj4+LYRzltMMJDR89Z5MqELkactktGq0RY12KGXl3qWNMjafBGdwAAC7s/JeT4bKyeNi+/j5nEssrE53ROrLmL99mKzTzcvohRol9j0o7puDHE5KM35fUWx4ROHbLlq1xreZXfcq4t0pNkydE9nZ/jB8Du4h0QJ3BlreV5DsNvXv5cwXsXdtLpsFOCQ9rBevO9J4ORcDRgKz+OEEM4BrLMGimMMelofICggcxGqApBLb3FHrI5cqSHPG1HPskiMqvV3PKUopcUy/JwcHegW5FC9V5HM+HyS0ur8XbyOcBmGYMntM06WpFKQcNVLx3NgH/uZ+QVt5n9YzIsbaCExtCGUGdGfA2jUyRt+SWq5ui/Y2/LGjJjT7qWUQ== kitty@nyaa-core"
authorized_key_note="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDc7iU7FrUt4UjQWxNOla1X/3RgtqeHPRY1fnVwHJ8qn5rMwIu+0MNkheQVVowPn3wLvFCqXaHR/HHNW9NxEX961CJb1aEHe5Y5EEjVbbuCVMQjZxHBnkBeSQjMDVsclPC1QC2K0wQwMz4Uc8TMzNNdUlKLHcjSyXOYE2FM4e+zJrgnaSfMa6avF7rkJrs0DRI6KNXXnMq+2GSsU0VV/zsWJ/eKIwVgbdFlMYJMiasEpBifOaYHFQ9TNUQIcCMKxpr0b7q0QaA/xUnA2uaOXlmPSOr9OESmuYCY+/pxiAF9Vz1ehH8wZ6fBZ3wnZ6j9FoGVlCsRETvwBfz4qGeg/G+Gka4XVaR0DPqXBo+gGnCc90w+J96VfmE9FUYYNz/3DOvTxNg5KaRwgea2QpOrSb9gbZTD3qLbdQh1EcQD1SeNw1uyc/LuPhjRE7y5tnsiYMpI9sPXRYyfaMKQ0xoropXcfpG6Sa8P5ndQ1n+Zm161kUZZ9tlceCkmuVSozZ9eLtmTXuyEGvwGxOqlluAI6J+5V9NDasUQgtqefXKyzERE8LC8Buwg1yRfhMD0Djirb3v7Lbaya4IyhdyDcVDNMXWPfCr3Hrjx6mlHuOnFm4I5oKOrOi+vFQML/w6fn/0eKsQkx/frYsieH6VOiQnI9TYZbh6TsfE4Q9CcM9GBdPAHww== nyaa-note@nyaa-link"
authorized_key_gate="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCmSgWoYIOI01DKCCSp12XeB0DixSIkZg+KKLz+LeM360W3730nfaOETOM+uZ/Gtl1H59ogSAHeppmbe1MEewbmJP7SWBQi3PCpbXZO7STIfprgL3HfjFo6iDSVDhm9kVRkUED47mtFZv+3Svga/xNNJpfy2LP4WaWBPd1kGtx7SCWtArib71P5MfPSAYdEGKekOYNyGihTDDvutbvNtOmTiG9Q165IaFHWT6srW257XOC6tQXus7OqOv4y/aMgjQJA1hZnu5C99ugyFMbXBOyOrKXAg6rP91haD488MwsMaANH15ltfrhhWPSC2ZA3/CRUtQf+k/ub9paZ/D14k1yHS7PSE6P/8/kDELJs+tWl7S12+Qvt3lxHTVaILuEvioyvVd+5sdRAr0UMFhlAu2QMRscG1Wa7r+aPIbkUbznFt3B+zH8KMICJa3ukRtDfdqHyux5viczo9BhJl71gFFj6Gr3EOI0KGNOvGyOe+2DP6S4ul0PSVnLHvnd0iIwDTTtOq86XYks5xaKoKJx6UyvVLYaiBOkfZKS5Awi66VrzQSbEdgyjM8ZN54KYmeuy5mmQqOuk1xVHxn9huPNtd1fwq5/lBuIB1FqmoQKIWUh5WOpucVxpmSDWI5fQUZx7xUp8h6LgBxF8wUu6SXGp9O96c9lucOTHiVarUtGKe+G31Q== nyaa-gate@nyaa-link"

# rm in order to make this action stateless
rm -f /etc/dropbear/authorized_keys
echo $authorized_key_core >> /etc/dropbear/authorized_keys
echo $authorized_key_note >> /etc/dropbear/authorized_keys
echo $authorized_key_gate >> /etc/dropbear/authorized_keys

# disable insecure access now that keys are set
uci set dropbear.@dropbear[0].PasswordAuth="off"
uci set dropbear.@dropbear[0].RootPasswordAuth="off"

uci commit dropbear

# === Static leases / Static Hosts ====

# creating and renaming hosts
echo 'Creating static lease hosts'
uci set dhcp.core=host
uci set dhcp.note=host
uci set dhcp.gate=host
uci set dhcp.aigent=host

# setting up the hosts
# nyaa-core
echo 'Setting up the static lease hosts'
uci set dhcp.core.name="nyaa-core"
uci set dhcp.core.dns="1"
uci set dhcp.core.mac="BA:A1:E7:A4:6A:82"
# uci set dhcp.core.mac="4C:CC:6A:01:F4:B5"
uci set dhcp.core.ip="192.168.1.2"
uci set dhcp.core.leasetime="12h"

# nyaa-poco
uci set dhcp.note.name="nyaa-poco"
uci set dhcp.note.dns="1"
uci set dhcp.note.mac="A4:50:46:6A:8E:31"
uci set dhcp.note.ip="192.168.1.3"
uci set dhcp.note.leasetime="12h"

# nyaa-gate
uci set dhcp.gate.name="nyaa-gate"
uci set dhcp.gate.dns="1"
uci set dhcp.gate.mac="9C:B6:D0:F1:18:2B"
uci set dhcp.gate.ip="192.168.1.4"
uci set dhcp.gate.leasetime="12h"

# nyaa-aigent
uci set dhcp.gate.name="nyaa-aigent"
uci set dhcp.gate.dns="1"
uci set dhcp.gate.mac="1C:1B:B5:C9:C0:89"
uci set dhcp.gate.ip="192.168.1.5"
uci set dhcp.gate.leasetime="12h"

# nyaa-note
uci set dhcp.note.name="nyaa-note"
uci set dhcp.note.dns="1"
uci set dhcp.note.mac="4C:66:41:E5:88:21"
uci set dhcp.note.ip="192.168.1.201"
uci set dhcp.note.leasetime="12h"

uci commit dhcp

# === Firewall

uci set firewall.ssh_link=rule
uci set firewall.ssh_link.name="ssh-link"
uci set firewall.ssh_link.target="ACCEPT"
uci set firewall.ssh_link.proto="tcp"
uci set firewall.ssh_link.src="wan"
uci set firewall.ssh_link.dest_port="22"

uci set firewall.ssh_core=redirect
uci set firewall.ssh_core.name="ssh-core"
uci set firewall.ssh_core.target="DNAT"
uci set firewall.ssh_core.proto="tcp"
uci set firewall.ssh_core.src="wan"
uci set firewall.ssh_core.src_dport="2222"
uci set firewall.ssh_core.dest="lan"
uci set firewall.ssh_core.dest_ip="192.168.1.2"
uci set firewall.ssh_core.dest_port="22"

uci commit firewall

# --- end of script ---

reboot
