#!/bin/bash
# vim: ts=4 sts=4 sw=4 noet
set -euo pipefail
if [[ ${DEBUG:-} = 1 ]]; then
	set -x
fi

if [[ -z "${PASSWORD:-}" ]]; then
	read -s -p "Password: " PASSWORD
	echo
fi

if [[ "$EUID" -ne 0 ]]; then
	echo "$PASSWORD" | sudo -S "$0" "$@"
	exit $?
else
	echo
fi

# Server / Graphical
# USB with key (optional)

help_message() {
	cat <<EOF
Usage: $(basename "$0") [options] <command>
Arch Linux installer for x86 systems and the Raspberry Pi 4

Commands:
  full <disk>                 wipe and use entire disk
  existing <esp> <system>     use provided partitions
  free <esp> <disk>           use existing esp and largest empty block
  pi4 <sdcard> [<ssid>]       provision sdcard with ALARM

Options:
  -u, --username <name>       name for wheel user (default: archie)
  -a, --authorized <file>     default '.ssh/authorized_keys' (set empty to skip)
  -t, --type <type>           type is 'desktop' or 'server' (default)
EOF

}

# Defaults
USERNAME='archie'
TYPE='server'
AUTHORIZED_KEYS="$HOME/.ssh/authorized_keys"

# Argument parsing
POSITIONAL=()
while [[ $# -gt 0 ]]; do
	key="$1"
	case "$key" in
		-h|--help)
			help_message
			exit
			;;
		-u|--username)
			USERNAME="${2:?$1 value not provided}"
			USERPASS="$(ask_pass 'User Password: ')"
			shift
			shift
			;;
		-a|--authorized-keys)
			AUTHORIZED_KEYS="${2:?$1 value not provided}"
			shift
			shift
			;;
		-t|--type)
			TYPE="${2:?$1 value not provided}"
			shift
			shift
			;;
		*)
			POSITIONAL+=("$1")
			shift
			;;
	esac
done

# Reset unrecognized arguments as positional
set -- "${POSITIONAL[@]}"

# ask password
ask_pass() {
	local PASSPROMPT="${1-Password: }"
	read -r -s -p "$PASSPROMPT" PASSWORD && echo
	echo "$PASSWORD"
}

# setup wifi configuration for systemd-networkd
# Requires: WIFI_SSID and WIFI_PASS
setup_wifi() {
	# Setup networkd dhcp for wifi
	cat <<EOF > root/etc/systemd/network/25-wireless.network
[Match]
Name=wlp*

[Network]
DHCP=yes
EOF
	# Setup wpa_supplicant conf
	cat <<EOF > root/etc/wpa_supplicant/wpa_supplicant-default.conf
ap_scan=1
country=NL
network={
    ssid="$1"
	psk="$2"
}
EOF
	# Enable wpa_supplicant for default
	ln -s /usr/lib/systemd/system/wpa_supplicant@.service root/etc/systemd/system/multi-user.target.wants/dhcpcd@default.service
}

# make sure disk provided is correct
confirm_disk() {
	if [[ -z ${1:-} ]]; then
		# make sure disk was given as an argument
		echo "No device path given..."
		exit 1
	elif [[ ! -b $1 ]]; then
		# check if provided path is a block device file
		echo "$1 is not a block device..."
		exit 1
	else
		# confirm with user
		echo "Using device $1"
		lsblk "$1"
		read -r -p "Are you sure? [y\N] " response
		if [[ ! $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
			exit
		fi
	fi
}

pi4_install() {
	local DISK="${1:?no device given}"

	# create 100M boot part, and remaining space as root part
	sfdisk "${DISK}" <<EOF
,100M,c
;
EOF
	# format boot
	mkfs.vfat "${DISK}p1"
	# format root, rewrite even if existing
	echo y | mkfs.ext4 "${DISK}p2"

	# mount all
	mkdir boot root
	mount "${DISK}p1" boot
	mount "${DISK}p2" root

	# download alarm
	curl -O -L -C - http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-4-latest.tar.gz
	# TODO: Maybe use aarch64 instead
	# using upstream recommended bsdtar
	bsdtar -xpf ArchLinuxARM-rpi-4-latest.tar.gz -C root
	sync

	# move boot to correct partition
	mv root/boot/* boot

	# add ssh reminder message for pacman-key init and populate
}

# partition() {
# 	partition_esp /dev/sda1
# 	partition_system /dev/sda2
# 	umount -qR /mnt || echo "Skipped unmount, as /mnt is not mounted"
# 	swapoff /dev/${NAME}lvm/swap || echo "Swap off skipped, as it is not on"
# 	vgchange -a n ${NAME}lvm || echo "Disable vg skipped, as ${NAME}lvm is not on"
# 	cryptsetup close /dev/mapper/${NAME}-crypt || echo "Crypt close skipped, as ${NAME}-crypt is not open"
#
# 	sgdisk -og ${DISK}
# 	sgdisk -n 1:0:+1G -c 1:${NAME}-boot -t 1:ef00 ${DISK}
# 	# sgdisk -n 2:0:+1G -c 2:${NAME}-boot -t 2:8300 ${DISK}
# 	sgdisk -n 2:0:0 -c 2:${NAME}-crypt -t 2:8308 ${DISK}
#
# 	mkfs.fat -F32 -n ESP ${DISK}1
# 	# mkfs.ext4 -L ${NAME}-boot ${DISK}2
#
# 	echo -n "$PASSWORD" | cryptsetup luksFormat --type luks2 ${DISK}2
# 	echo -n "$PASSWORD" | cryptsetup open --key-file - ${DISK}2 ${NAME}-crypt
# 	pvcreate -y -ff /dev/mapper/${NAME}-crypt
# 	vgcreate -y ${NAME}lvm /dev/mapper/${NAME}-crypt
# 	lvcreate -L 8G ${NAME}lvm -n swap
# 	lvcreate -l +100%FREE ${NAME}lvm -n root
#
# 	mkswap -L ${NAME}-swap /dev/${NAME}lvm/swap
# 	mkfs.btrfs -L ${NAME}-root /dev/${NAME}lvm/root
#
# 	mount /dev/${NAME}lvm/root /mnt
# 	mkdir -p /mnt/boot
# 	mount ${DISK}1 /mnt/boot
# 	# mkdir -p /mnt/boot
# 	# mount ${DISK}2 /mnt/boot
# 	swapon /dev/${NAME}lvm/swap
# }

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
	:
}

setup_graphical_env() {
	# install and enable display manager
	# plymouth?
	:
}

usb_unlock_key() {
	# If usb given, add to luks keys and crypttab
	:
}

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

		echo "root:${USERPASS}" | chpasswd
		mkdir -p /root/.ssh
		chmod 700 /root/.ssh
		echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINgiVkcrXrIJk2T6tsQjGvF4YcCNbcef8eaSFPInnPSQ kitty@nyaa-core" > /root/.ssh/authorized_keys
		chmod 600 /root/.ssh/authorized_keys

		pacman -S --noconfirm --needed zsh
		useradd -m -G wheel -s /bin/zsh kitty
		echo "kitty:${USERPASS}" | chpasswd
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
		pacman -S --noconfirm --needed amd-ucode intel-ucode

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
			initrd	/amd-ucode.img
			initrd	/intel-ucode.img
			initrd	/initramfs-linux.img
			options	root=/dev/${NAME}lvm/root resume=/dev/${NAME}lvm/swap
		EOF2

		cat <<-EOF2 > /boot/loader/entries/fallback.conf
			title	Arch Linux (Fallback)
			linux	/vmlinuz-linux
			initrd	/amd-ucode.img
			initrd	/intel-ucode.img
			initrd	/initramfs-linux-fallback.img
			options	root=/dev/${NAME}lvm/root resume=/dev/${NAME}lvm/swap
		EOF2
		EOF
		# options	cryptdevice=LABEL root=/dev/${NAME}lvm/root rw resume=/dev/${NAME}lvm/swap
}

system_services() {
	arch-chroot /mnt bash -s <<-EOF
		systemctl enable systemd-timesyncd
		EOF
}

# Command switching
case "${1:?no command provided}" in
	full)
		DISK="${2:?disk not provided}"
		# clear disk
		# create esp
		# create system remaining
		echo NYI
		exit 1
		;;
	existing)
		ESP="${2:?esp not provided}"
		SYSTEM="${3:?system not provided}"
		# set esp
		# set system (and fix part type)
		echo NYI
		exit 1
		;;
	free)
		ESP="${2:?esp not provided}"
		DISK="${3:?Disk not provided}"
		# set esp
		# use largest empty space as system
		echo NYI
		exit 1
		;;
	pi4)
		MODE=pi4
		SDCARD="${2:?sdcard not provided}"
		WIFI_SSID="${3:-}"
		if [[ -n $WIFI_SSID ]]; then
			WIFI_PASS="$(ask_pass 'WiFi Passphrase: ')"
		fi
		confirm_disk "$SDCARD"
		WORKDIR="$(mktemp -d)"
		pushd $WORKDIR
		pi4_install "$SDCARD"
		if [[ -n "WIFI_SSID" ]]; then
			setup_wifi "$WIFI_SSID" "$WIFI_PASS"
		fi
		umount -R "$SDCARD"
		rm -rf "$WORKDIR"
		exit
		;;
esac
