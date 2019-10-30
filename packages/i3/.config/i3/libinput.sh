#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

setup_touchpad () {
  xinput set-prop "$1" "libinput Tapping Enabled" 1
  xinput set-prop "$1" "libinput Natural Scrolling Enabled" 1
}

if [[ "$(hostname)" == "nyaa-gate" ]]; then
  setup_touchpad "DLL082A:01 06CB:76AF Touchpad"
elif [[ "$(hostname)" == "nyaa-work" ]]; then
  setup_touchpad "DELL081C:00 044E:121F Touchpad"
fi
