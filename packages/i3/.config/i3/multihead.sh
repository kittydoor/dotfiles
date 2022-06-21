#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# NYAA-CORE

nyaa_core_x11_single() {
  xrandr --output HDMI-1 --primary --mode 2560x1440 --pos 0x0 --rotate normal --output HDMI-2 --off
}

nyaa_core_x11_dual() {
  xrandr --output HDMI-1 --primary --mode 2560x1440 --pos 0x0 --rotate normal --output HDMI-2 --mode 1920x1080 --pos 2560x360 --rotate normal
}

nyaa_core_x11_alternate() {
  xrandr --output HDMI-1 --off --output HDMI-2 --primary --mode 1920x1080 --pos 0x0 --rotate normal
}

nyaa_core_x11_default() {
  nyaa_core_x11_dual
}

# NYAA-GATE
# TODO: Add config

# Old work setup for wayland, nowadays using include for system specific sway configs
# NYAA_WORK_WAYLAND_MAIN='output eDP-1 pos 0 360 res 1920x1080 bg #000000 solid_color'
# NYAA_WORK_WAYLAND_SECONDARY='output DP-1 pos 1920 0 res 3840x2160 bg #000000 solid_color scale 1.5'
# NYAA_WORK_WAYLAND_SETUP="${NYAA_WORK_WAYLAND_MAIN}; ${NYAA_WORK_WAYLAND_SECONDARY}; focus output eDP-1"
#
# nyaa_work_wayland_single() {
#   # TODO: Figure out why the command below prints tons of newlines
#   swaymsg "${NYAA_WORK_WAYLAND_SETUP}; output eDP-1 enable; output DP-1 disable" > /dev/null
# }
#
# nyaa_work_wayland_dual() {
#   swaymsg "${NYAA_WORK_WAYLAND_SETUP}; output eDP-1 enable; output DP-1 enable" > /dev/null
# }
#
# nyaa_work_wayland_default() {
#   nyaa_work_wayland_single
# }

COMMAND="${HOSTNAME//-/_}_${XDG_SESSION_TYPE:-}_${1:-default}"

if [[ $(type -t "${COMMAND}") == function ]]; then
  ${COMMAND}
fi
