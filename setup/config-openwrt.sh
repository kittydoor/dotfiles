#!/bin/sh
set -o xtrace
set -e

DEFAULT_DNS="1.1.1.1 8.8.8.8"

help_message() {
  echo 'Usage: ssh root@192.168.1.1 "NYAAKEY=foo KITTIESKEY=bar sh -s" < config-openwrt.sh'
}

help_exit() {
  echo
  help_message
  exit ${1:-1}
}

safety_check() {
  # === Safety Checks ===========================
  # Ensure not running on the wrong host
  # By default, the hostname should be OpenWrt,
  # and for updates, it should be nyaa-link
  if [ "OpenWrt" != "$HOSTNAME" ] && [ "nyaa-link" != "$HOSTNAME" ]; then
    echo 'Hostname not (default) OpenWrt or (configured) nyaa-link.'
    echo 'Exitting to prevent unintended damage to host...'
    help_exit 2
  fi

  # REQUIRED ENVIRONMENT VARIABLES
  # NYAAKEY - nyaa-wifi key
  # KITTIESKEY - kitties key

  if [ -z "$NYAAKEY" ]; then
    echo 'NYAAKEY (personal network) not defined, exitting...'
    help_exit
  fi

  if [ -z "$KITTIESKEY" ]; then
    echo 'KITTIESKEY (guest network) not defined, exitting...'
    help_exit
  fi
}

system_config() {
  # === Update root password ====================
  # Update root password (which affects luci logins)
  # SSH as root is disabled later on
  # To create hash, use
  # mkpasswd --method=md5 <password>
  # OpenWrt has sha hashes disabled, in normal circumstances sha-512 is prefered
  echo 'Updating root password'
  sed -i 's|root:.*|root:$1$yRnQ/.6B$3xJHJ1LbzU2ymTIA9wU/n1:0:0:99999:7:::|' /etc/shadow

  # === Update hostname =========================
  HOSTNAME="nyaa-link"
  echo "Setting hostname to $HOSTNAME"
  uci set system.@system[0].hostname="$HOSTNAME"

  # === Set the Time Zone =======================
  TIMEZONE='CET-1CEST,M3.5.0,M10.5.0/3'
  ZONENAME='Europe/Amsterdam'
  echo 'Setting timezone to' $TIMEZONE
  uci set system.@system[0].timezone="$TIMEZONE"
  echo 'Setting zone name to' $ZONENAME
  uci set system.@system[0].zonename="$ZONENAME"

  uci commit system
}

packages() {
  # === Update the software packages ============
  # Download and update all the interesting packages
  # Some of these are pre-installed, but there is no harm in
  # updating/installing them a second time.
  echo 'Installing/Updating select software packages'
  if update_out=$(opkg update \
      && opkg install luci \
      && opkg install luci-ssl \
      && opkg install tmux \
      && opkg install vim); then
    echo 'Success: luci luci-ssl tmux vim'
  else
    echo 'There was a problem...'
    echo
    echo "${update_out}"
    exit 3
  fi
}

lan_config() {
  # Configure dns for lan
  uci set network.lan.peerdns=0
  uci set network.lan.dns="${DEFAULT_DNS}"
  uci commit network
}

guest_config() {
  # Create guest interface
  uci set network.guest=interface
  uci set network.guest.type=bridge
  uci set network.guest.ifname=eth0.2
  uci set network.guest.proto=static
  uci set network.guest.ipaddr=192.168.2.1
  uci set network.guest.netmask=255.255.255.0
  uci set network.guest.peerdns=0
  uci set network.guest.dns="${DEFAULT_DNS}"
  uci commit network

  # Create dhcp server for guest network
  uci set dhcp.guest=dhcp
  uci set dhcp.guest.interface=guest
  uci set dhcp.guest.start=100
  uci set dhcp.guest.leasetime=12h
  uci set dhcp.guest.limit=150
  uci commit dhcp

  # Creating firewall rules for guest network
  uci set firewall.guest=zone
  uci set firewall.guest.name=guest
  uci set firewall.guest.network=guest
  uci set firewall.guest.forward=REJECT
  uci set firewall.guest.output=ACCEPT
  uci set firewall.guest.input=REJECT

  uci set firewall.guest_fwd=forwarding
  uci set firewall.guest_fwd.src=guest
  uci set firewall.guest_fwd.dest=wan

  uci set firewall.guest_dhcp=rule
  uci set firewall.guest_dhcp.name=guest_dhcp
  uci set firewall.guest_dhcp.src=guest
  uci set firewall.guest_dhcp.target=ACCEPT
  uci set firewall.guest_dhcp.proto=udp
  uci set firewall.guest_dhcp.dest_port=67-68

  uci set firewall.guest_dns=rule
  uci set firewall.guest_dns.name=guest_dns
  uci set firewall.guest_dns.src=guest
  uci set firewall.guest_dns.target=ACCEPT
  uci set firewall.guest_dns.proto=tcpudp
  uci set firewall.guest_dns.dest_port=53

  uci commit firewall
}

wireless_config() {
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
  uci set wireless.nyaa_wifi="wifi-iface"
  uci set wireless.nyaa_wifi5="wifi-iface"
  uci set wireless.kitties="wifi-iface"
  uci set wireless.kitties5="wifi-iface"

  # === 1c) Assign the options ==================
  echo 'Assigning some options'
  uci set wireless.nyaa_wifi.mode="ap"
  uci set wireless.nyaa_wifi5.mode="ap"
  uci set wireless.kitties.mode="ap"
  uci set wireless.kitties5.mode="ap"

  uci set wireless.nyaa_wifi.network="lan"
  uci set wireless.nyaa_wifi5.network="lan"
  uci set wireless.kitties.network="guest"
  uci set wireless.kitties5.network="guest"

  # === 1d) AP specific options =================
  echo 'Assigning ap specific options'
  uci set wireless.nyaa_wifi.hidden="1"
  uci set wireless.nyaa_wifi5.hidden="1"
  uci set wireless.kitties.hidden="0"
  uci set wireless.kitties5.hidden="0"

  uci set wireless.nyaa_wifi.device="radio1"
  uci set wireless.nyaa_wifi5.device="radio0"
  uci set wireless.kitties.device="radio1"
  uci set wireless.kitties5.device="radio0"

  # === 1e) Assign the ssid and encryption ======

  uci set wireless.nyaa_wifi.ssid="nyaa-wifi"
  uci set wireless.nyaa_wifi5.ssid="nyaa-wifi"
  uci set wireless.kitties.ssid="kitties"
  uci set wireless.kitties5.ssid="kitties5"

  WI_ENC="psk2+ccmp"

  uci set wireless.nyaa_wifi.encryption=$WI_ENC
  uci set wireless.nyaa_wifi5.encryption=$WI_ENC
  uci set wireless.kitties.encryption=$WI_ENC
  uci set wireless.kitties5.encryption=$WI_ENC

  uci set wireless.nyaa_wifi.key=$NYAAKEY
  uci set wireless.nyaa_wifi5.key=$NYAAKEY
  uci set wireless.kitties.key=$KITTIESKEY
  uci set wireless.kitties5.key=$KITTIESKEY

  # Isolate devices in network from each other
  uci set wireless.kitties.isolate=1
  uci set wireless.kitties5.isolate=1

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
}

ssh_config() {
# === Configuring dropbear
  authorized_key_link="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYgX1bygjCOUxRDoTVj9VegcJnf7v0ICJEISc8Ak7hxSg1UyINT5ltdb3ztfv9lVijrUlDLM0sB8Bv16QiN+H2p5ewf0qfLnJ9hWmX7kO7ZaUnJ/nDiKNHKt4/2rEWJmUFUcOheiy4mSatp2uJlBG0sannTUEupydi6tSquoTplTQzHIsVvj3yx2uY3/xo6ZDr3FrrX6GFRtiNMSMg9uE3XSiWgihGLTQhItIsM2Ze7fzgb5oLShxH0AKUZIscKZ2zk74pD5EUuI/I9GvKWTJG07Z1rYAHKSy3XEzzhl7T+2tL1kMSwyOt9Qc/Mz2HFo/4h1ipeAwx+AzjeJVGB4UVUa9Ub0H0ybGghDCziNUTwE7cUK7agOMvVqhU3rphT7R2xLE+CDrGHQghaNI4InYE31drtKRd3ZDCoFht1HeCyEAC2hwgObHlW4zhmLgw4hNpptV0v27qeqM75fKnXUKYPe5gHeYLS5cwaX6MM01QffJMqKS5MyL7mZMoPF2tgVQiOZ27B4x1+xxP7mmBMEerAxdsyUcbLQZtZ2+l3tHnlIir3PeYu5wYDQlbJj9DxqnlpimyuI+ncaGbJxJ6pxhZ46tQnjlqzmT+spJYUjFTKLoiYEyisM2rYp8BtscZH6Ny5KUUwYg/aF7CsfpOaAb09yejHzA1MbX+GpiegA19iQ== root@nyaa-link shared"
  echo "$authorized_key_link" > /etc/dropbear/authorized_keys

  # disable insecure access now that keys are set
  uci set dropbear.@dropbear[0].RootPasswordAuth="off"
  uci set dropbear.@dropbear[0].PasswordAuth="off"

  uci commit dropbear
}

dnsmasq_config() {
  # Disable rebind protection
  # (required for allowing dns records to return private ips)
  # such as ones routed via wireguard

  echo 'Configuring dnsmasq'

  uci set dhcp.@dnsmasq[0].rebind_protection=0
  uci commit dhcp
}

dhcp_config() {
  # === Static leases / Static Hosts ====
  # TODO: Maybe use /etc/ethers instead

  # creating and renaming hosts
  echo 'Creating static lease hosts'
  uci set dhcp.core=host
  uci set dhcp.poco=host
  uci set dhcp.gate=host
  uci set dhcp.work=host
  uci set dhcp.note=host

  # setting up the hosts
  # nyaa-core
  echo 'Setting up the static lease hosts'

  # Note: MAC can be multiple, space separated
  CORE_MAC="4C:CC:6A:01:F4:B5"
  POCO_MAC="A4:50:46:6A:8E:31"
  GATE_MAC="9C:B6:D0:F1:18:2B"
  WORK_MAC="1C:1B:B5:C9:C0:89"
  NOTE_MAC="4C:66:41:E5:88:21"

  uci set dhcp.core.name="nyaa-core"
  uci set dhcp.core.mac="$CORE_MAC"
  # uci set dhcp.core.mac="BA:A1:E7:A4:6A:82" # bridge
  uci set dhcp.core.ip="192.168.1.2"
  uci set dhcp.core.leasetime="12h"

  # nyaa-poco
  uci set dhcp.poco.name="nyaa-poco"
  uci set dhcp.poco.mac="$POCO_MAC"
  uci set dhcp.poco.ip="192.168.1.3"
  uci set dhcp.poco.leasetime="12h"

  # nyaa-gate
  uci set dhcp.gate.name="nyaa-gate"
  uci set dhcp.gate.mac="$GATE_MAC"
  uci set dhcp.gate.ip="192.168.1.4"
  uci set dhcp.gate.leasetime="12h"

  # nyaa-work
  uci set dhcp.work.name="nyaa-work"
  uci set dhcp.work.mac="$WORK_MAC"
  uci set dhcp.work.ip="192.168.1.5"
  uci set dhcp.work.leasetime="12h"

  # nyaa-note
  uci set dhcp.note.name="nyaa-note"
  uci set dhcp.note.mac="$NOTE_MAC"
  uci set dhcp.note.ip="192.168.1.201"
  uci set dhcp.note.leasetime="12h"

  uci commit dhcp
}

firewall_config() {
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

  uci set firewall.minecraft_core=redirect
  uci set firewall.minecraft_core.name="minecraft-core"
  uci set firewall.minecraft_core.target="DNAT"
  uci set firewall.minecraft_core.proto="tcp"
  uci set firewall.minecraft_core.src="wan"
  uci set firewall.minecraft_core.src_dport="25565"
  uci set firewall.minecraft_core.dest="lan"
  uci set firewall.minecraft_core.dest_ip="192.168.1.2"
  uci set firewall.minecraft_core.dest_port="25565"

  uci commit firewall
}

# === Configure System ========================
# Exit if running on wrong host
safety_check
# Password, hostname, timezone
system_config
# Install and update some packages
packages
# Lan config (dns)
lan_config
# Guest network interface, dhcp, and firewall rules
guest_config
# Configure wireless radios
# (requires guest config for kitties to have interface to bind to)
wireless_config
# Remove ssh root or password access
ssh_config
# Disable rebind protection
# (required for allowing dns records to return private ips)
# such as ones routed via wireguard
dnsmasq_config
# Dhcp leases
dhcp_config
# Firewall, and port forwards
firewall_config

# === Reload all services =====================
# TODO: Figure out why 'service' doesn't work with 'sh -s' call
# ...It seems on a new interactive sh, 'service' can't be found
# ...and 'which service' returns empty even when service is working
# Hostname and Timezone
/etc/init.d/system reload
# Wireless
/etc/init.d/network reload
# Dropbear
/etc/init.d/dropbear reload
# Dhcp settings
/etc/init.d/dnsmasq reload
# Static leases (requires dnsmasq too)
/etc/init.d/odhcpd reload
# Firewall
/etc/init.d/firewall reload
