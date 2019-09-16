#!/bin/bash
set -o xtrace
set -euo pipefail

cd /tmp

curl -L -O https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
tar -xvf yay.tar.gz

cd yay

makepkg -sirc
