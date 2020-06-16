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

partition() {
	if [[ -z ${1:-} ]]; then
		return 1
	fi

	umount -qR /mnt || echo "Skipped unmount, as /mnt is not mounted"
	swapoff /dev/nodelvm/swap || echo "Swap off skipped, as it is not on"
	vgchange -a n nodelvm || echo "Disable vg skipped, as nodelvm is not on"
	cryptsetup close /dev/mapper/node-crypt || echo "Crypt close skipped, as node-crypt is not open"

	sgdisk -og $1
	sgdisk -n 1:0:+1G -c 1:node-boot -t 1:ef00 $1
	# sgdisk -n 2:0:+1G -c 2:node-boot -t 2:8300 $1
	sgdisk -n 2:0:0 -c 2:node-crypt -t 2:8308 $1

	mkfs.fat -F32 -n ESP $11
	# mkfs.ext4 -L node-boot $12

	echo -n "$PASSWORD" | cryptsetup luksFormat --type luks2 $12
	echo -n "$PASSWORD" | cryptsetup open --key-file - $12 node-crypt
	pvcreate -y -ff /dev/mapper/node-crypt
	vgcreate -y nodelvm /dev/mapper/node-crypt
	lvcreate -L 8G nodelvm -n swap
	lvcreate -l +100%FREE nodelvm -n root

	mkswap -L node-swap /dev/nodelvm/swap
	mkfs.btrfs -L node-root /dev/nodelvm/root

	mount /dev/nodelvm/root /mnt
	mkdir -p /mnt/boot
	mount $11 /mnt/boot
	# mkdir -p /mnt/boot
	# mount $12 /mnt/boot
	swapon /dev/nodelvm/swap
}

install_arch() {
	if [[ -z ${1:-} ]]; then
		return 1
	fi

	timedatectl set-ntp true

	pacman -S --noconfirm --needed reflector
	reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

	pacstrap /mnt base linux linux-firmware btrfs-progs lvm2 vi sudo man-db man-pages texinfo openssh dhcpcd

	cat <<-EOF > /mnt/etc/crypttab
		node-crypt UUID=$(blkid -s UUID -o value $12)
		EOF

	genfstab -U /mnt >> /mnt/etc/fstab

	arch-chroot /mnt bash -s <<-EOF
		set -euo pipefail
		set -x

		ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
		hwclock --systohc
		sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
		locale-gen
		echo 'LANG=en_US.UTF-8' > /etc/locale.conf
		echo 'nyaa-node' > /etc/hostname
		cat <<-EOF2 > /etc/hosts
			127.0.0.1	localhost
			::1		localhost
			127.0.1.1	nyaa-node.lan nyaa-node
			EOF2
		systemctl enable dhcpcd
		systemctl enable sshd
		EOF
}

setup_user() {
	arch-chroot /mnt bash -s <<-EOF
		set -euo pipefail
		set -x

		echo "root:${PASSWORD}" | chpasswd
		mkdir -p /root/.ssh
		chmod 700 /root/.ssh
		echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINgiVkcrXrIJk2T6tsQjGvF4YcCNbcef8eaSFPInnPSQ kitty@nyaa-core" > /root/.ssh/authorized_keys
		chmod 600 /root/.ssh/authorized_keys

		pacman -S --noconfirm --needed zsh
		useradd -m -G wheel -s /bin/zsh kitty
		echo "kitty:${PASSWORD}" | chpasswd
		mkdir -p /root/.ssh
		chmod 700 /root/.ssh
		echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINgiVkcrXrIJk2T6tsQjGvF4YcCNbcef8eaSFPInnPSQ kitty@nyaa-core" > /root/.ssh/authorized_keys
		chmod 600 /root/.ssh/authorized_keys
		EOF
}

setup_bootloader() {
	if [[ -z ${1:-} ]]; then
		return 1
	fi

	arch-chroot /mnt bash -s <<-EOF
		set -euo pipefail
		set -x

		pacman -S --noconfirm --needed mkinitcpio-systemd-tool busybox cryptsetup openssh tinyssh tinyssh-convert mc

		sed -i 's/^HOOKS=.*/HOOKS=(base keyboard autodetect modconf block filesystems fsck systemd sd-lvm2 systemd-tool)/' /etc/mkinitcpio.conf

		cat <<-EOF2 > /etc/mkinitcpio-systemd-tool/config/crypttab
			node-crypt UUID=$(blkid -s UUID -o value $12) none luks
			EOF2

		cat <<-EOF2 > /etc/mkinitcpio-systemd-tool/config/fstab
			/dev/nodelvm/root	/sysroot	auto	x-systemd.device-timeout=9999h 0 1
			/dev/nodelvm/swap	none		swap	x-systemd.device-timeout=9999h 0 0
			EOF2

		systemctl enable initrd-cryptsetup.path
		systemctl enable initrd-tinysshd
		systemctl enable initrd-debug-progs
		systemctl enable initrd-sysroot-mount
		ssh-keygen -A

		mkinitcpio -P

		# TODO: Ensure microcode loading works
		pacman -S --noconfirm --needed intel-ucode

		bootctl --path=/boot install

		mkdir -p /boot/loader
		cat <<-EOF2 > /boot/loader/loader.conf
			default arch.conf
			timeout 3
			console-mode max
			editor no
		EOF2

		mkdir -p /boot/loader/entries
		cat <<-EOF2 > /boot/loader/entries/arch.conf
			title	Arch Linux
			linux	/vmlinuz-linux
			initrd	/intel-ucode.img
			initrd	/initramfs-linux.img
			options	resume=/dev/nodelvm/swap
		EOF2

		cat <<-EOF2 > /boot/loader/entries/fallback.conf
			title	Arch Linux (Fallback)
			linux	/vmlinuz-linux
			initrd	/intel-ucode.img
			initrd	/initramfs-linux-fallback.img
			options	resume=/dev/nodelvm/swap
		EOF2
		EOF
		# options	cryptdevice=LABEL root=/dev/nodelvm/root rw resume=/dev/nodelvm/swap
}

TARGET_DISK=/dev/sdg
if (( $# < 1 )); then
	partition $TARGET_DISK
	install_arch $TARGET_DISK
	setup_user
	setup_bootloader $TARGET_DISK
else
	$@ $TARGET_DISK
fi
