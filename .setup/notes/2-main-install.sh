#!/bin/bash

strap_packages () {
  pacstrap /mnt base # can also append here
}

configure_fstab () {
  cat << EOF > /mnt/etc/fstab
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>
EOF
  genfstab -U /mnt >> /mnt/etc/fstab
}

chroot_and_config () {
  cat << EOF | arch-chroot /mnt bash
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
# nyaa-core, remote, gate, proxy, company-name
echo nyaa-aigent > /etc/hostname
passwd
EOF
}

chroot_and_config
