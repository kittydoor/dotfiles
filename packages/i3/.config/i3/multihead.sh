#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

nyaa_core_single () {
  echo nyi
}

nyaa_core_dual () {
  echo nyi
}

nyaa_work_single () {
  xrandr --output HDMI-2 --off --output HDMI-1 --off --output DP-1 --off --output eDP-1 --primary --mode 1920x1080 --pos 0x360 --rotate normal --output DP-2 --off
}

nyaa_work_dual () {
  xrandr --output HDMI-2 --off --output HDMI-1 --off --output DP-1 --mode 2560x1440 --pos 1920x0 --rotate normal --output eDP-1 --primary --mode 1920x1080 --pos 0x360 --rotate normal --output DP-2 --off
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
"nyaa-work single")
  nyaa_work_single
  ;;
"nyaa-work dual")
  nyaa_work_dual
  ;;
"nyaa-work default")
  nyaa_work_single
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
