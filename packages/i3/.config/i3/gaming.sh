#!/bin/bash
set -euo pipefail
set -o xtrace

# This script starts up the win-gaming vm, synergy, and audio (through spice) trio
if [[ ${HOSTNAME:-} != nyaa-core ]]; then
  echo Will only run on nyaa-core. Quitting...
  exit 10
fi

# Start the gaming vm
# TODO: Perhaps check if it is already running rather than || true, maybe it doesn't exist?
virsh -c qemu:///system start win-gaming || true

# Start the synergy daemon
killall synergys || true
synergys -c ~/.config/i3/synergy.conf

# Connect to it
# TODO: Sound issues with virt-viewer
# virt-viewer -c qemu:///system win-gaming
# Slightly better with virt-manager
virt-manager -c qemu:///system --show-domain-console win-gaming
