#!/bin/bash
set -euo pipefail

help_message() {
  cat <<EOF
Usage: $0 <img>
EOF
}

if [[ -z ${1:-} ]]; then
  echo "No image specified..."
  help_message
  exit 1
elif [[ ! -f $1 ]]; then
  echo "File $1 not found..."
  exit 2
fi


if [ "$EUID" -ne 0 ]; then
  sudo "$0" "$@"
  exit $?
fi

./shared/umount-all.sh

echo "Writing image..."
pv "$1" | dd bs=4M iflag=fullblock of=/dev/mmcblk0 oflag=direct
echo "Disk safe to remove"
