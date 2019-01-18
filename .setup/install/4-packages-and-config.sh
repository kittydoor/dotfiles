#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# Install packages
grep -o '^[^#]*' pkglist.txt | pacman -S --needed -
# Can "tr '\n' ' '" to replace newlines with spaces, but pacman stdin recognizes multiple lines

pkgfile --update

visudo

# setup.d stuff

# setup intel microcode

# stow stuff
# startx
