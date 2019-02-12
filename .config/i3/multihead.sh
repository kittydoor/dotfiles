#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

nyaa_core_single () {
  xrandr --output HDMI-2 --off --output HDMI-1 --primary --mode 2560x1440 --pos 0x0 --rotate normal
}

nyaa_core_dual () {
  xrandr --output HDMI-2 --mode 1920x1080 --pos 2560x0 --rotate normal --output HDMI-1 --primary --mode 2560x1440 --pos 0x0 --rotate normal
}

nyaa_aigent_single () {
  xrandr --output VIRTUAL1 --off --output eDP1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP1 --off --output HDMI2 --off --output HDMI1 --off --output DP2 --off
}

nyaa_aigent_dual () {
  xrandr --output VIRTUAL1 --off --output eDP1 --primary --mode 1920x1080 --pos 0x360 --rotate normal --output DP1 --mode 2560x1440 --pos 1920x0 --rotate normal --output HDMI2 --off --output HDMI1 --off --output DP2 --off
}

nyaa_gate_single () {
  exit 2
}

nyaa_gate_dual () {
  exit 2
}

case "$(hostname) ${1:-single}" in
"nyaa-core single")
  nyaa_core_single
  ;;
"nyaa-core dual")
  nyaa_core_dual
  ;;
"nyaa-core default")
  nyaa_core_dual
  ;;
"nyaa-aigent single")
  nyaa_aigent_single
  ;;
"nyaa-aigent dual")
  nyaa_aigent_dual
  ;;
"nyaa-aigent default")
  nyaa_aigent_single
  ;;
"nyaa-gate single")
  nyaa_gate_single
  ;;
"nyaa-gate dual")
  nyaa_gate_dual
  ;;
"nyaa-gate default")
  nyaa_gate_single
  ;;
*)
  exit 1
  ;;
esac
