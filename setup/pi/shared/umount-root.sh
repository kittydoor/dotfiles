#!/bin/bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  sudo "$0" "$@"
  exit $?
fi

for part in $(mount | grep /dev/mmcblk0p2 | awk '{ print $1 }'); do
  echo "Unmounting $part"
  umount "$part"
done
