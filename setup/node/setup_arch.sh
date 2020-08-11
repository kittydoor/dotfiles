#!/bin/bash
# vim: ts=4 sts=4 sw=4 noet
set -euo pipefail
set -x

# System setup steps
# Partition
# - Whole disk
# - Percent/Size of disk size
# - Existing ESP, use biggest empty space
# - Existing ESP and System
# Format system (always)
# Format esp (optional)
# Mount system, create /boot, and mount esp
# Bootstrap system
# Setup bootloader
# Create user (ensure given shell installed)
# Setup user ssh auth keys


# Get short hostname
# Get disks (part or nopart)
# Server / Graphical
# USB with key (optional)

help_message() {
	echo <<EOF
Usage: $0 [MODE] [OPTION]...
Arch Linux installer for x86 systems and the Raspberry Pi 4

OPTIONs:
  -t|--type [x86|pi4]		System type (Arch Linux for x86 and ALARM for pi4)
  -d|--disk <disk>
  -e|--esp <disk>		ESP Partition if not using whole disk mode
  -u|--username <name>		Username for wheel user
  -a|--authorized <file>	Authorized keys file

MODEs:
  clean		Clean disk and partition whole disk
  none		Don't partition / use provided partitions
  percent	NYI Clean diak and partition percentage of space
  gb		NYI Clean disk and partition xGB of space
  tb		NYI Clean disk and partition xTB of space
  free		NYI Use largest continous empty block for system (must manually partition the ESP)


EXAMPLEs:
  $1 -m whole -d /dev/sda -t x86 -u kitty
EOF

}

POSITIONAL=()
while [[ $# -gt 0 ]]; do
	key="$1"
	case "$key" in
		-h|--help)
			help_message
			exit
			;;
		-d|--disk)
			DISK="$2"
			shift
			shift
			;;
		-e|--esp)
			ESP="$2"
			shift
			shift
			;;
		--default)
			DEFAULT=YES
			shift
			;;
		*)
			POSITIONAL+=("$1")
			shift
			;;
	esac
done

set -- "${POSITIONAL[@]}"

	

partition() {
	partition_esp /dev/sda1
	partition_system /dev/sda2 
	umount -qR /mnt || echo "Skipped unmount, as /mnt is not mounted"
	swapoff /dev/${NAME}lvm/swap || echo "Swap off skipped, as it is not on"
	vgchange -a n ${NAME}lvm || echo "Disable vg skipped, as ${NAME}lvm is not on"
	cryptsetup close /dev/mapper/${NAME}-crypt || echo "Crypt close skipped, as ${NAME}-crypt is not open"

	sgdisk -og ${DISK}
	sgdisk -n 1:0:+1G -c 1:${NAME}-boot -t 1:ef00 ${DISK}
	# sgdisk -n 2:0:+1G -c 2:${NAME}-boot -t 2:8300 ${DISK}
	sgdisk -n 2:0:0 -c 2:${NAME}-crypt -t 2:8308 ${DISK}

	mkfs.fat -F32 -n ESP ${DISK}1
	# mkfs.ext4 -L ${NAME}-boot ${DISK}2

	echo -n "$PASSWORD" | cryptsetup luksFormat --type luks2 ${DISK}2
	echo -n "$PASSWORD" | cryptsetup open --key-file - ${DISK}2 ${NAME}-crypt
	pvcreate -y -ff /dev/mapper/${NAME}-crypt
	vgcreate -y ${NAME}lvm /dev/mapper/${NAME}-crypt
	lvcreate -L 8G ${NAME}lvm -n swap
	lvcreate -l +100%FREE ${NAME}lvm -n root

	mkswap -L ${NAME}-swap /dev/${NAME}lvm/swap
	mkfs.btrfs -L ${NAME}-root /dev/${NAME}lvm/root

	mount /dev/${NAME}lvm/root /mnt
	mkdir -p /mnt/boot
	mount ${DISK}1 /mnt/boot
	# mkdir -p /mnt/boot
	# mount ${DISK}2 /mnt/boot
	swapon /dev/${NAME}lvm/swap
}

partition() {

}

format_system() {
	DISK="${1:?}"
	LABEL="${2:?}"

	umount -q "$DISK"
	umount -qR /mnt

}

format_esp() {
	DISK="${1:?}"
	LABEL="${2:?}"

	umount -q "$DISK"
	umount -qR /mnt/boot



}

setup_ssh_keys() {

}

setup_graphical_env() {
	# install and enable display manager
	# plymouth?
	;
}

usb_unlock_key() {
	# If usb given, add to luks keys and crypttab
	;
}

if (( $# != 3 )); then
	echo "usage: $0 <host (e.g. core)> <disk (e.g. /dev/sda)>"
fi

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

install_arch() {
	timedatectl set-ntp true

	pacman -S --noconfirm --needed reflector
	reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

	pacstrap /mnt base linux linux-firmware btrfs-progs lvm2 vi sudo man-db man-pages texinfo openssh dhcpcd

	cat <<-EOF > /mnt/etc/crypttab
		${NAME}-crypt UUID=$(blkid -s UUID -o value ${DISK}2)
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
		echo 'nyaa-${NAME}' > /etc/hostname
		cat <<-EOF2 > /etc/hosts
			127.0.0.1	localhost
			::1		localhost
			127.0.1.1	nyaa-${NAME}.lan nyaa-${NAME}
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
	#TODO: Add keys from dotfiles repo
}

setup_bootloader() {
	arch-chroot /mnt bash -s <<-EOF
		set -euo pipefail
		set -x

		pacman -S --noconfirm --needed mkinitcpio-systemd-tool busybox cryptsetup openssh tinyssh tinyssh-convert mc

		sed -i 's/^HOOKS=.*/HOOKS=(base keyboard autodetect modconf block filesystems fsck systemd sd-lvm2 systemd-tool)/' /etc/mkinitcpio.conf

		cat <<-EOF2 > /etc/mkinitcpio-systemd-tool/config/crypttab
			${NAME}-crypt UUID=$(blkid -s UUID -o value ${DISK}2) none luks
			EOF2

		cat <<-EOF2 > /etc/mkinitcpio-systemd-tool/config/fstab
			/dev/${NAME}lvm/root	/sysroot	auto	x-systemd.device-timeout=9999h 0 1
			/dev/${NAME}lvm/swap	none		swap	x-systemd.device-timeout=9999h 0 0
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
			options	root=/dev/${NAME}lvm/root resume=/dev/${NAME}lvm/swap
		EOF2

		cat <<-EOF2 > /boot/loader/entries/fallback.conf
			title	Arch Linux (Fallback)
			linux	/vmlinuz-linux
			initrd	/intel-ucode.img
			initrd	/initramfs-linux-fallback.img
			options	root=/dev/${NAME}lvm/root resume=/dev/${NAME}lvm/swap
		EOF2
		EOF
		# options	cryptdevice=LABEL root=/dev/${NAME}lvm/root rw resume=/dev/${NAME}lvm/swap
}

NAME="$1"
DISK="$2"

# Clear /mnt
umount -qR /mnt

# Partition or mount system

# Partition or mount esp/boot

# Install arch system
install_arch
setup_bootloader

# Setup system
setup_user kitty
[[ -z "${GRAPHICAL:-}" ]] || setup_graphical_env
