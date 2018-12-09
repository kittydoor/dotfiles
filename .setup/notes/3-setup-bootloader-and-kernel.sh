#!/bin/bash
set -o errexit
set -o nounset
set -o xtrace
set -o pipefail

setup_grub () {
  cat <<"EOF" | arch-chroot /mnt bash
set -o errexit
set -o nounset
set -o xtrace
set -o pipefail

pacman -S --needed grub efibootmgr

# TODO
# KERNEL
# Add hooks to /etc/mkinitcpio.conf
# example (additions in capitals, all must be lowercase):
# base udev autodetect KEYBOARD modconf block ENCRYPT LVM2 filesystems ~keyboard~ fsck
# keyboard for keys, keymap (optional) for non-us, encrypt for encryption, lvm2 for lvm


mkinitcpio -p linux

sed -i 's/^#GRUB_ENABLE_CRYPTODISK=[yn]/GRUB_ENABLE_CRYPTODISK=y/' /etc/default/grub
sed -i "s/^GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$(blkid -s UUID -o value /dev/sda3):cryptlvm\"/" /etc/default/grub
# TODO: Make the code above add the option no matter previous configured state, rather than only if empty
# TODO: Does this evaluate blkid in the heredoc or in the chroot?

grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
EOF
}

ls /sys/firmware/efi/efivars > /dev/null # check if in uefi mode
setup_grub
