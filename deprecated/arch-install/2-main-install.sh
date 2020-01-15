#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

strap_packages () {
  pacstrap /mnt --needed base zsh dialog wpa_supplicant git # can also append here
}

configure_fstab () {
  cat <<"EOF" > /mnt/etc/fstab
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>
EOF
  genfstab -U /mnt >> /mnt/etc/fstab
}

chroot_and_config () {
  cat <<"EOF" | arch-chroot /mnt bash
set -o errexit
set -o nounset
set -o xtrace
set -o pipefail

# time
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc

# locale
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# hostname
# nyaa-core, remote, gate, proxy, company-name
echo nyaa-aigent > /etc/hostname

# users
id -u kitty || useradd -m -G users,wheel -s /bin/zsh kitty # lazy eval for useradd
cat <<"EOF2" | chpasswd -e
root:$6$acKP91SbTv0uqzmP$BB4gBLdfWYjWGWX8GWHETJyxMcOo7eX433ePJaXsvXja8.T0IkYYUns0DTzTn5bMhVg.43R76Icbf3TiHRgXe/
kitty:$6$QZBx6bYoJJUgUkN6$KwUTLc8M4LkTBhEiajdWgJ.qv3zk9pgvZwgpAAlIFGWYItlilosL/zydx8w335TF1RNiYDDC0qkVrtOuma6pA1
EOF2

su kitty -c "git clone https://gitlab.com/kittydoor/dotfiles /home/kitty/dotfiles"
EOF
}

strap_packages
configure_fstab
chroot_and_config
