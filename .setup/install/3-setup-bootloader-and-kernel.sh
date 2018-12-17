#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

setup_grub () {
  cat <<"EOF" | arch-chroot /mnt bash
set -o errexit
set -o nounset
set -o xtrace
set -o pipefail

pacman -S --needed grub efibootmgr

# check file is one of expected states
grep "^HOOKS=(base udev autodetect keyboard modconf block encrypt lvm2 filesystems fsck)$" /etc/mkinitcpio.conf ||
  {
    grep "^HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)$" /etc/mkinitcpio.conf &&
    sed -i "s/^HOOKS=([a-z ]*)$/HOOKS=(base udev autodetect keyboard modconf block encrypt lvm2 filesystems fsck)/" /etc/mkinitcpio.conf
  }
# TODO: Make the code actually add the options to any state, rather than only this one

mkinitcpio -p linux
grep "^GRUB_ENABLE_CRYPTODISK=y$" /etc/default/grub ||
  {
    grep "^#GRUB_ENABLE_CRYPTODISK=[yn]$" /etc/default/grub &&
    sed -i 's/^#GRUB_ENABLE_CRYPTODISK=[yn]/GRUB_ENABLE_CRYPTODISK=y/' /etc/default/grub
  }

grep "^GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$(blkid -s UUID -o value /dev/sda3):cryptlvm\"" /etc/default/grub ||
  {
    grep "^GRUB_CMDLINE_LINUX=\"\"$"  /etc/default/grub &&
    sed -i "s/^GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$(blkid -s UUID -o value /dev/sda3):cryptlvm\"/" /etc/default/grub
  }
# TODO: Make the code above add the option no matter previous configured state, rather than only if empty
# TODO: Does this evaluate blkid in the heredoc or in the chroot?

grep -P "^cryptboot\t/dev/sda2\tnone\tluks$" /etc/crypttab ||
  echo -e "cryptboot\t/dev/sda2\tnone\tluks" >> /etc/crypttab

grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
EOF
}

ls /sys/firmware/efi/efivars > /dev/null # check if in uefi mode
setup_grub
