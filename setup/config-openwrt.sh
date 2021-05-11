#!/bin/sh
set -o xtrace
set -e

DEFAULT_DNS="1.1.1.1 8.8.8.8"

help_message() {
  echo 'Usage: ssh root@192.168.1.1 "NYAAKEY=foo KITTIESKEY=bar NOTKEY=baz sh -s" < config-openwrt.sh'
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

  if [ -z "$NOTKEY" ]; then
    echo 'NOTKEY (not network) not defined, exitting...'
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

wan_config() {
  # Configure dns for wan
  uci set network.wan.peerdns=0
  uci set network.wan.dns="${DEFAULT_DNS}"
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
  uci set firewall.guest.input=ACCEPT
  uci set firewall.guest.output=ACCEPT
  uci set firewall.guest.forward=ACCEPT

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

not_config() {
  # Create not (network of things) interface
  uci set network.not=interface
  uci set network.not.type=bridge
  uci set network.not.ifname=eth0.3
  uci set network.not.proto=static
  uci set network.not.ipaddr=192.168.3.1
  uci set network.not.netmask=255.255.255.0
  uci set network.not.peerdns=0
  uci set network.not.dns="${DEFAULT_DNS}"
  uci commit network

  # Create dhcp server for not network
  uci set dhcp.not=dhcp
  uci set dhcp.not.interface=not
  uci set dhcp.not.start=100
  uci set dhcp.not.leasetime=12h
  uci set dhcp.not.limit=150
  uci commit dhcp

  # Creating firewall rules for not network
  uci set firewall.not=zone
  uci set firewall.not.name=not
  uci set firewall.not.network=not
  uci set firewall.not.input=REJECT
  uci set firewall.not.output=ACCEPT
  uci set firewall.not.forward=REJECT

  uci set firewall.not_dhcp=rule
  uci set firewall.not_dhcp.name=not_dhcp
  uci set firewall.not_dhcp.src=not
  uci set firewall.not_dhcp.target=ACCEPT
  uci set firewall.not_dhcp.proto=udp
  uci set firewall.not_dhcp.dest_port=67-68

  uci set firewall.not_dns=rule
  uci set firewall.not_dns.name=not_dns
  uci set firewall.not_dns.src=not
  uci set firewall.not_dns.target=ACCEPT
  uci set firewall.not_dns.proto=tcpudp
  uci set firewall.not_dns.dest_port=53

  uci commit firewall
}

not_lan_forwardings() {
  uci set firewall.not_lan_fw=forwarding
  uci set firewall.not_lan_fw.src=not
  uci set firewall.not_lan_fw.dest=lan

  uci set firewall.lan_not_fw=forwarding
  uci set firewall.lan_not_fw.src=lan
  uci set firewall.lan_not_fw.dest=not

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
  uci set wireless.nyaa_not="wifi-iface"

  # === 1c) Assign the options ==================
  echo 'Assigning some options'
  uci set wireless.nyaa_wifi.mode="ap"
  uci set wireless.nyaa_wifi5.mode="ap"
  uci set wireless.kitties.mode="ap"
  uci set wireless.kitties5.mode="ap"
  uci set wireless.nyaa_not.mode="ap"

  uci set wireless.nyaa_wifi.network="lan"
  uci set wireless.nyaa_wifi5.network="lan"
  uci set wireless.kitties.network="guest"
  uci set wireless.kitties5.network="guest"
  uci set wireless.nyaa_not.network="not"

  # === 1d) AP specific options =================
  echo 'Assigning ap specific options'
  uci set wireless.nyaa_wifi.hidden="1"
  uci set wireless.nyaa_wifi5.hidden="1"
  uci set wireless.kitties.hidden="0"
  uci set wireless.kitties5.hidden="0"
  uci set wireless.nyaa_not.hidden="0"

  uci set wireless.nyaa_wifi.device="radio1"
  uci set wireless.nyaa_wifi5.device="radio0"
  uci set wireless.kitties.device="radio1"
  uci set wireless.kitties5.device="radio0"
  uci set wireless.nyaa_not.device="radio1"

  # === 1e) Assign the ssid and encryption ======

  uci set wireless.nyaa_wifi.ssid="nyaa-wifi"
  uci set wireless.nyaa_wifi5.ssid="nyaa-wifi"
  uci set wireless.kitties.ssid="kitties"
  uci set wireless.kitties5.ssid="kitties5"
  uci set wireless.nyaa_not.ssid="nyaa-not"

  WI_ENC="psk2+ccmp"

  uci set wireless.nyaa_wifi.encryption=$WI_ENC
  uci set wireless.nyaa_wifi5.encryption=$WI_ENC
  uci set wireless.kitties.encryption=$WI_ENC
  uci set wireless.kitties5.encryption=$WI_ENC
  uci set wireless.nyaa_not.encryption=$WI_ENC

  uci set wireless.nyaa_wifi.key=$NYAAKEY
  uci set wireless.nyaa_wifi5.key=$NYAAKEY
  uci set wireless.kitties.key=$KITTIESKEY
  uci set wireless.kitties5.key=$KITTIESKEY
  uci set wireless.nyaa_not.key=$NOTKEY

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

uci_dhcp_lease() {
  # Args:
  # 1 -> shortname
  # 2 -> name
  # 3 -> mac
  # 4 -> address

  uci set dhcp."$1"=host
  uci set dhcp."$1".name="$2"
  uci set dhcp."$1".mac="$3"
  uci set dhcp."$1".ip="$4"
  uci set dhcp."$1".leasetime=12h
}

dhcp_config() {
  # === Static leases / Static Hosts ====
  # TODO: Maybe use /etc/ethers instead

  echo 'Setting up the static leases'

  # WORK_MAC="1C:1B:B5:C9:C0:89"
  # PI4A_WIFI_MAC="DC:A6:32:51:64:F0"
  # PI4B_WIFI_MAC=""
  # NOTE_MAC="4C:66:41:E5:88:21"

  # Remove all lease rules
  for section in $(uci show dhcp | sed -n 's/dhcp.\([a-z0-9_]*\)=host/\1/p'); do
    uci delete dhcp."$section"
  done

  # Create new lease rules
  uci_dhcp_lease gear nyaa-gear 'BC:A5:11:BE:C0:A9' '192.168.1.2'
  uci_dhcp_lease node nyaa-node 'A8:A1:59:0B:CB:EA' '192.168.1.11'
  uci_dhcp_lease pi4a nyaa-pi4a 'DC:A6:32:51:64:ED' '192.168.1.12'
  uci_dhcp_lease pi4b nyaa-pi4b 'DC:A6:32:4B:FB:FA' '192.168.1.13'
  uci_dhcp_lease core nyaa-core '4C:CC:6A:01:F4:B5' '192.168.1.21'
  uci_dhcp_lease poco nyaa-poco 'A4:50:46:6A:8E:31' '192.168.1.22'
  uci_dhcp_lease gate nyaa-gate '9C:B6:D0:F1:18:2B' '192.168.1.23'
  uci_dhcp_lease work nyaa-work 'A4:83:E7:4E:B4:1E' '192.168.1.24'

  # Create smart device lease rules
  uci_dhcp_lease plug_alpha plug_alpha     '24:62:AB:39:A5:CD' '192.168.3.11'
  uci_dhcp_lease plug_beta plug_beta       'C8:2B:96:53:AD:53' '192.168.3.12'
  uci_dhcp_lease plug_charlie plug_charlie 'D8:F1:5B:B4:FC:35' '192.168.3.13'
  uci_dhcp_lease plug_delta plug_delta     '24:62:AB:42:06:4B' '192.168.3.14'

  uci_dhcp_lease light_bedroom light_bedroom '2C:F4:32:B2:D4:CF' '192.168.3.21'

  uci commit dhcp
}

port_forward() {
  # Args:
  # 1 -> name
  # 2 -> protocol
  # 3 -> src_dport
  # 4 -> host address
  # 5 -> dport

  uci set firewall."$1"=redirect
  uci set firewall."$1".name="$1"
  uci set firewall."$1".target=DNAT
  uci set firewall."$1".proto="$2"
  uci set firewall."$1".src=wan
  uci set firewall."$1".src_dport="$3"
  uci set firewall."$1".dest=lan
  uci set firewall."$1".dest_ip="$4"
  uci set firewall."$1".dest_port="$5"
}

firewall_config() {
  # === Firewall

  # Setup rules
  uci set firewall.ssh_link=rule
  uci set firewall.ssh_link.name="ssh-link"
  uci set firewall.ssh_link.target="ACCEPT"
  uci set firewall.ssh_link.proto="tcp"
  uci set firewall.ssh_link.src="wan"
  uci set firewall.ssh_link.dest_port="22"

  # Setup port forwardings
  for section in $(uci show firewall | sed -n 's/firewall.\([a-z0-9_]*\)=redirect/\1/p'); do
    uci delete firewall."$section"
  done

  port_forward wireguard_pi4a 51823 51823 192.168.1.3
  port_forward wireguard_pi4b 51824 51824 192.168.1.4
  port_forward wireguard_core 51825 51825 192.168.1.5

  port_forward ssh_core tcp 2222 22 192.168.1.5
  # port_forward minecraft_core 25565 25565 192.168.1.5

  uci commit firewall
}

# === Configure System ========================
# Exit if running on wrong host
safety_check
# Password, hostname, timezone
system_config
# Install and update some packages
packages
# Wan config (dns)
wan_config
# Guest network interface, dhcp, and firewall rules
guest_config
# Not network
not_config
# Let lan and not talk to each other
# TODO: Perhaps restrict the rules? Or somehow only allow mqtt to pi4 or other select traffic?
not_lan_forwardings
# Configure wireless radios
# (requires guest config for kitties to have interface to bind to)
# (requiest not config for nyaa-not to have interface to bind to)
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
