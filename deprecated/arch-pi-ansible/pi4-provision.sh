#sshpass -p alarm ssh alarm@alarmpi.lan 'echo root | su - root -c "bash -s"' <<EOF
sshpass -p alarm ssh kitty@nyaa-pi4.lan 'echo root | su - root -c "bash -s"' <<EOF
set -o xtrace
pacman -Syu sudo vim
#sed 's|# %wheel ALL=(ALL) ALL|%wheel ALL=(ALL) ALL /etc/sudoers|' /etc/sudoers
EOF

## The default root password is root.
#
#pacman-key --init
#pacman-key --populate archlinuxarm
#
#useradd -m -G wheel kitty
#passwd kitty
#
#ssh kitty@alarmpi.lan
#
#su root
#
#echo nyaa-pi4 > /etc/hostname
#
#reboot
#
#ssh kitty@nyaa-pi4.lan
#
#userdel alarm
#
## PermitRootLogin no
## PasswordAuthentication no
#
