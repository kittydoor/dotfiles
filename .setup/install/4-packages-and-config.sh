#!/bin/bash

# Install packages
sed -e "/^#/d" -e "s/#.*//" pkglist.txt | pacman -S --needed -
# TODO: This doesn't seem to work with lines that have inline comments

pkgfile --update

visudo

# setup.d stuff

# setup intel microcode

# stow stuff
# startx