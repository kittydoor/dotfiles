#!/bin/bash
# vim: ts=4 sts=4 sw=4 noet
set -euo pipefail
set -x

if [[ -z "${PASSWORD:-}" ]]; then
	read -s -p "Password: " PASSWORD
	echo
fi

if [[ "$EUID" -ne 0 ]]; then
	echo "$PASSWORD" | sudo -S PASSWORD="$PASSWORD" "$0" "$@"
	exit $?
else
	echo
fi

DISKS="/dev/sdb /dev/sdd /dev/sdf"
NAMES=(alpha beta gamma delta epsilon)

COUNTER=0
for disk in $DISKS; do
	cryptsetup close /dev/mapper/cerberus-${NAMES[COUNTER]} || true

	sgdisk -og $disk
	sgdisk -n 1:0:0: -c 1:cerberus-${NAMES[COUNTER]} -t 1:8308 $disk

	echo -n "$PASSWORD" | cryptsetup luksFormat --type luks2 ${disk}1
	echo -n "$PASSWORD" | cryptsetup open --key-file - ${disk}1 cerberus-${NAMES[COUNTER]}

	if [[ -z ${CONTAINERS:-} ]]; then
		CONTAINERS="/dev/mapper/cerberus-${NAMES[COUNTER]}"
	else
		CONTAINERS="$CONTAINERS /dev/mapper/cerberus-${NAMES[COUNTER]}"
	fi

	COUNTER=$((COUNTER + 1))
done

mkfs.btrfs -f -d raid5 -m raid1 -L cerberus $CONTAINERS
