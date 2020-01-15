#!/bin/bash
set -o xtrace
set -euo pipefail

pacman -S --noconfirm --needed vagrant

su kitty -c "vagrant plugin install vagrant-libvirt"
su kitty -c "vagrant plugin install vagrant-hostmanager"

mkdir -p /etc/qemu
cat <<"EOF" > /etc/qemu/bridge.conf
allow virbr0
EOF
chmod 644 /etc/qemu/bridge.conf

virsh net-autostart default
