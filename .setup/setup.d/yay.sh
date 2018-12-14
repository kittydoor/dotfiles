#/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

cd /tmp

curl -L -O https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
tar -xvf yay.tar.gz

cd yay

makepkg -sirc
