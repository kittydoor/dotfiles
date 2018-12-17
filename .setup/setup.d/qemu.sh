#!/bin/bash
pacman -S --needed \
  qemu \
  libvirt \
  firewalld \
  ebtables \
  dnsmasq \
  bridge-utils \
  virt-manager \
  polkit-gnome

systemctl enable --now libvirtd
