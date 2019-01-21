#!/bin/bash
set -o xtrace
set -euo pipefail

pacman -S --needed \
  docker

systemctl enable --now docker
