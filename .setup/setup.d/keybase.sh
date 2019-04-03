#!/bin/bash
set -euo pipefail
pacman -S keybase kbfs keybase-gui

echo '# Post installation instructions, do as user:'
echo '$ systemctl enable --now --user keybase'
echo '$ keybase config set mountdir ~/kbfs'
echo '$ mkdir ~/kbfs'
echo '$ systemctl enable --now --user kbfs'
