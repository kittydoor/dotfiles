#!/bin/bash
set -euo pipefail

if [[ -z "${PASSWORD:-}" ]]; then
  read -s -p "Password: " PASSWORD
  echo
fi

if [[ "$EUID" -ne 0 ]]; then
  echo "$PASSWORD" | sudo -S PASSWORD="$PASSWORD" "$0" "$@"
  exit $?
fi

if [[ ! -b /dev/mapper/crypt ]]; then
  echo "Opening crypt"
  echo -n "$PASSWORD" | sudo cryptsetup open --key-file - /dev/md127 crypt
  sleep 1
fi

if [[ ! -b /dev/mapper/data-data ]]; then
  echo "Activating lv"
  lvchange -a y /dev/mapper/data
fi

if ! mountpoint -q /data; then
  echo "Mounting data"
  mount /dev/mapper/data-data /data
fi

if [[ ! -b /dev/mapper/backup ]]; then
  echo "Opening backup"
  echo -n "$PASSWORD" | sudo cryptsetup open --key-file - /dev/sde1 backup
  sleep 1
fi

if ! mountpoint -q /backup; then
  echo "Mounting backup"
  mount /dev/mapper/backup /backup
fi

echo "Starting docker"
systemctl start docker

echo "Starting k3s"
systemctl start k3s
