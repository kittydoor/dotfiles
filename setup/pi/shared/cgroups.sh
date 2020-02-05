#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
  sudo "$0" "$@"
  exit $?
fi

./shared/mount-boot.sh

# original:
# net.ifnames=0 dwc_otg.lpm_enable=0 console=ttyAMA0,115200 console=tty1 root=LABEL=writable rootfstype=ext4 elevator=deadline rootwait fixrtc
# new
# ipv6.disable=1 cgroup_enable=memory
echo "net.ifnames=0 dwc_otg.lpm_enable=0 console=ttyAMA0,115200 console=tty1 root=LABEL=writable rootfstype=ext4 elevator=deadline rootwait fixrtc ipv6.disable=1 cgroup_enable=memory" > /mnt/boot/firmware/nobtcmd.txt

./shared/umount-boot.sh
