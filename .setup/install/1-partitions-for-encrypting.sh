#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

yns () {
  read -p "Y/S/N" choice
  case "$choice" in
    y|Y ) echo "Continuing...";;
    s|S ) /bin/bash;;
    * ) echo "Exitting"; exit 1;;
  esac
}

setup_partitioning () {
  # gdisk /dev/sda, partitions:
  # - esp /dev/sda1 ef00 1G /efi
  # - boot /dev/sda2 8300 1G /boot
  # - lvm /dev/sda3 8e00 384G / and /home
  sgdisk -o /dev/sda
  sgdisk -n 1:0:+1G -t 1:ef00 /dev/sda
  sgdisk -n 2:0:+1G -t 2:8300 /dev/sda
  sgdisk -n 3:0:+384G -t 3:8e00 /dev/sda
}

setup_partition_all () {
  setup_partition_esp
  setup_partition_boot
  setup_partition_lvm
}

setup_partition_esp () {
  # esp
  mkfs.fat -F 32 -n ESP /dev/sda1
}

setup_partition_boot () {
  # boot
  cryptsetup luksFormat /dev/sda2
  cryptsetup open /dev/sda2 cryptboot
  mkfs.ext4 -L boot /dev/mapper/cryptboot
}

setup_partition_lvm () {
  setup_partition_lvm_crypt
  setup_partition_lvm_pv
  setup_partition_lvm_vg
  setup_partition_lvm_lv
  setup_partition_lvm_fs
}

setup_partition_lvm_crypt () {
  # lvm
  cryptsetup luksFormat --type luks2 /dev/sda3
  cryptsetup open /dev/sda3 cryptlvm
}

setup_partition_lvm_pv () {
  pvcreate -ff /dev/mapper/cryptlvm
}

setup_partition_lvm_vg () {
  vgcreate cryptlvm /dev/mapper/cryptlvm # could also be named differently
}

setup_partition_lvm_lv () {
  lvcreate -L 128G cryptlvm -n root
  lvcreate -l 100%FREE cryptlvm -n home
}

setup_partition_lvm_fs () {
mkfs.ext4 -L root /dev/cryptlvm/root
mkfs.ext4 -L home /dev/cryptlvm/home
}

open_crypts () {
  cryptsetup open /dev/sda2 cryptboot
  cryptsetup open /dev/sda3 cryptlvm
}

mount_all () {
  mount /dev/cryptlvm/root /mnt

  mkdir -p /mnt/home
  mkdir -p /mnt/efi
  mkdir -p /mnt/boot

  mount /dev/cryptlvm/home /mnt/home
  mount /dev/sda1 /mnt/efi
  mount /dev/mapper/cryptboot /mnt/boot
}

close_all () {
  umount -R /mnt || true

  vgchange -an /dev/mapper/cryptlvm || true

  cryptsetup close /dev/mapper/cryptboot || true
  cryptsetup close /dev/mapper/cryptlvm || true
}

if [ -z ${1-} ]; then
  setup_partitioning
  setup_partition_all
  mount_all
else
  $1
fi
