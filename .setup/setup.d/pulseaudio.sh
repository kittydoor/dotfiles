#!/bin/bash
set -o xtrace
set -euo pipefail

# Setup Script for PulseAudio
pacman -S \
	pavucontrol \
	pulseaudio-alsa \
	pulseaudio

# pulseaudio - core package
# -alsa - proxy for programs that don't support pa
# pavucontrol - PA Volume Control
# echo "blacklist pcspkr" >> /etc/modprobe.d/blacklist.conf
