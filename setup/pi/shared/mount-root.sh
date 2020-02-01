#!/bin/bash
set -euo pipefail
set -x

if [ "$EUID" -ne 0 ]; then
  sudo "$0" "$@"
  exit $?
fi

./shared/umount-root.sh

mkdir -p /mnt/root
mount /dev/mmcblk0p2 /mnt/root
echo "Mounted root"
