#!/bin/bash
set -e

help_message() {
  cat <<EOF
Usage: $0 <user-data> <wifi-psk> [<hostname>]
EOF
}

if [[ -z $1 ]]; then
  echo "No user-data file specified..."
  help_message
  exit 1
elif [[ ! -f $1 ]]; then
  echo "File $1 not found..."
  exit 2
fi

if [[ -z $2 ]]; then
  echo "wifi-psk not specified..."
  help_message
  exit 3
fi

if [ "$EUID" -ne 0 ]; then
  sudo "$0" "$@"
  exit $?
fi

./shared/mount-boot.sh

export WIFI_PSK="$2"
envsubst < "$1" > /mnt/boot/user-data

if [[ -n $3 ]]; then
  sed -i "s/^hostname: nyaa-pi4$/hostname: $3/"  /mnt/boot/user-data
fi

cat /mnt/boot/user-data

./shared/umount-boot.sh
