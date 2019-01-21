#!/bin/bash
set -o xtrace
set -euo pipefail

pacman -S --needed \
  qemu \
  libvirt \
  firewalld \
  ebtables \
  dnsmasq \
  bridge-utils \
  virt-manager \
  virt-viewer \
  polkit-gnome

systemctl enable --now libvirtd
