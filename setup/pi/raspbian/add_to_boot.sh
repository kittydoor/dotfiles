#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
  sudo "$0" "$@"
  exit $?
fi

mount /dev/mmcblk0p1 /mnt/boot

envsubst < wpa_supplicant.conf > /mnt/boot/wpa_supplicant.conf

# : null command
# >| clobber (i.e. truncate file even if it has contect)
:>| /mnt/boot/ssh

cat /mnt/boot/wpa_supplicant.conf

umount /dev/mmcblk0p1
