#!/bin/bash
set -o xtrace
set -euo pipefail

pacman -S vagrant

su kitty -c "vagrant plugin install vagrant-libvirt"
su kitty -c "vagrant plugin install vagrant-hostmanager"

mkdir -p /etc/qemu
cat <<"EOF" > /etc/qemu/bridge.conf
allow virbr0
allow virbr1
EOF
chmod 644 /etc/qemu/bridge.conf

if ! virsh net-list | grep vagrant-libvirt > /dev/null; then
  temp_file=$(mktemp)
  cat <<"EOF" > ${temp_file}
<network ipv6='yes'>
  <name>vagrant-libvirt</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr1' stp='on' delay='0'/>
  <mac address='52:54:00:41:96:c0'/>
  <ip address='192.168.121.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.121.1' end='192.168.121.254'/>
    </dhcp>
  </ip>
</network>
EOF
  virsh net-define ${temp_file};
  echo creating;
  rm ${temp_file};
fi

virsh net-autostart default
virsh net-autostart vagrant-libvirt
