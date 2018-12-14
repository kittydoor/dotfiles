#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

case "$(hostname) ${1:single}" in
"nyaa-core single")
  xrandr --output HDMI-2 --auto --off, mode "default"
  ;;
"nyaa-core double")
  xrandr --output HDMI-2 --auto --right-of HDMI-1, mode "default"
  ;;
"nyaa-remote single")
  ;;
"nyaa-remote double")
  ;;
"nyaa-aigent single")
  xrandr --output VIRTUAL1 --off --output eDP1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP1 --off --output HDMI2 --off --output HDMI1 --off --output DP2 --off
  ;;
"nyaa-aigent double")
  xrandr --output VIRTUAL1 --off --output eDP1 --primary --mode 1920x1080 --pos 0x360 --rotate normal --output DP1 --mode 2560x1440 --pos 1920x0 --rotate normal --output HDMI2 --off --output HDMI1 --off --output DP2 --off
  ;;
*)
  exit 1
  ;;
esac
