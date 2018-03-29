#!/bin/bash
if [[ "$(hostname)" == "nyaa-gate" ]]; then
  xinput set-prop "DLL082A:01 06CB:76AF Touchpad" "libinput Tapping Enabled" 1
  xinput set-prop "DLL082A:01 06CB:76AF Touchpad" "libinput Natural Scrolling Enabled" 1
fi
