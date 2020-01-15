#!/bin/bash
set -o xtrace
set -euo pipefail

pacman -S rng-tools

systemctl enable --now rngd
