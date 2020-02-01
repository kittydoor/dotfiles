#!/bin/bash
set -euo pipefail
set -x

if [ "$EUID" -ne 0 ]; then
  sudo "$0" "$@"
  exit $?
fi

./shared/umount-boot.sh

mkdir -p /mnt/boot
mount /dev/mmcblk0p1 /mnt/boot
echo "Mounted boot"
