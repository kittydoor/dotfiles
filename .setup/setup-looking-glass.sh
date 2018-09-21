#!/bin/bash
set -e

looking_glass_init="/usr/local/bin/looking-glass-init.sh"

cat <<'EOF' > $looking_glass_init
#!/bin/sh

touch /dev/shm/looking-glass
chown kitty:kvm /dev/shm/looking-glass
chmod 660 /dev/shm/looking-glass
EOF

chmod +x $looking_glass_init

cat <<'EOF' > /etc/systemd/system/looking-glass-init.service
[Unit]
Description=Create shared memory for looking glass

[Service]
Type=oneshot
ExecStart=/usr/local/bin/looking-glass-init.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now looking-glass-init.service

# = install client
su kitty -c "yay -S looking-glass"

# === MANUAL ===
# = Calculate Size =
# width x height x 4 x 2 = total bytes
# total bytes / 1024 / 1024 = total mebibytes
# M = total mebibytes + 2
# for 1920x1080 it is 17.82. rounded to nearest power of two
# 32
#
# = Add shmem device =
#
# virsh -c qemu:///system
# list --all
# edit [vmname]
#
#...
#<devices>
#    ...
#  <shmem name='looking-glass'>
#    <model type='ivshmem-plain'/>
#    <size unit='M'>32</size>
#  </shmem>
#</devices>
#...
# = install IVSHMEM Host to Windows Guest =
# install driver
# install looking-glass-host
