#!/bin/bash
set -euo pipefail
set -o xtrace

if [[ -z ${1:-} ]]; then
  echo "No device name given..."
  exit 1;
elif [[ ! -b $1 ]]; then
  echo "$1 is not a device file..."
  exit 1;
else
  echo "Using device $1"
  read -r -p "Are you sure? [y/N] " response
  if [[ ! $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    exit
  fi
fi

# Create boot partition of size 100M, and the rest is root
sfdisk "$1" <<EOF
,100M,c
;
EOF

DIR="$(mktemp -d)"

mkfs.vfat "$1p1"
echo y | mkfs.ext4 "$1p2"

cd "$DIR"

mkdir boot root
mount "$1p1" boot
mount "$1p2" root

curl -O -L -C - http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-4-latest.tar.gz
bsdtar -xpf ArchLinuxARM-rpi-4-latest.tar.gz -C root
sync

mv root/boot/* boot

umount boot root

cd ..
rm -rf "$DIR"
