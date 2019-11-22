#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

nyaa_work_x11_single() {
  xrandr --output HDMI-2 --off --output HDMI-1 --off --output DP-1 --off --output eDP-1 --primary --mode 1920x1080 --pos 0x360 --rotate normal --output DP-2 --off
}

nyaa_work_x11_dual() {
  xrandr --output HDMI-2 --off --output HDMI-1 --off --output DP-1 --mode 2560x1440 --pos 1920x0 --rotate normal --output eDP-1 --primary --mode 1920x1080 --pos 0x360 --rotate normal --output DP-2 --off
}

nyaa_work_wayland_setup(){
  MAIN='output eDP-1 pos 0 360 res 1920x1080 bg #000000 solid_color'
  SECONDARY='output DP-1 pos 1920 0 res 3840x2160 bg #000000 solid_color scale 1.5'
  swaymsg "${MAIN}; ${SECONDARY}; focus output eDP-1"
}

nyaa_work_wayland_single() {
  nyaa_work_wayland_setup
  #TODO: Figure out why the command below prints tons of newlines
  swaymsg 'output eDP-1 enable; output DP-1 disable' > /dev/null
}

nyaa_work_wayland_dual() {
  nyaa_work_wayland_setup
  swaymsg 'output eDP-1 enable; output DP-1 enable' > /dev/null
}

nyaa_work_wayland_default() {
  nyaa_work_wayland_single
}

COMMAND="${HOSTNAME//-/_}_${XDG_SESSION_TYPE:-}_${1:-default}"

if [[ $(type -t "${COMMAND}") == function ]]; then
  ${COMMAND}
fi
