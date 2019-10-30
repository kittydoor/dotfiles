#!/bin/bash
set -euo pipefail

help_message() {
  echo 'Volume control helper script'
  echo
  echo "Usage: $0 <option> [inc/dec amount]"
  echo '          set <percentage>'
  echo
  echo 'Options:'
  echo '  inc     increments audio by percentage'
  echo '  dec     decrements audio by percentage'
  echo '  set     sets audio to percentage'
  echo '  toggle  toggles audio mute'
  echo '  mute    mutes audio'
  echo
  echo 'inc and dec snap to the next multiple of 5 if no amount provided'
}

echoerr() {
  >&2 echo -n -e "\e[34m!Error:\e[39m "
  >&2 echo "$@"
}

if ! type pactl >/dev/null; then
  echoerr "'pactl' command not found. This script depends on pactl."
  exit 1
fi;

if [[ -z ${1:-} ]]; then
  echoerr "No arguments given"
  help_message
  exit 1
fi

check_parse() {
  #if ! [[ $1 =~ ^(100\|[[1-9][0-9]\|[9-0])$ ]]; then
  if ! [[ $1 =~ ^([1-9][0-9]|[0-9])$ ]]; then
    echoerr "Amount given is not a valid integer (e.g. 50)"
    exit 1
  fi
}

inc_vol() {
  pactl set-sink-volume @DEFAULT_SINK@ "+$1%"
  smart_mute
}

dec_vol() {
  pactl set-sink-volume @DEFAULT_SINK@ "-$1%"
  smart_mute
}

inc_snap() {
  VOLUME_STR=$(current_volume)
  VOLUME=${VOLUME_STR%\%}
  DELTA="$(( 5 - (VOLUME % 5) ))"
  inc_vol "${DELTA}"
}

dec_snap() {
  VOLUME_STR=$(current_volume)
  VOLUME=${VOLUME_STR%\%}
  DELTA="$(( VOLUME % 5 ))"
  if [[ ${DELTA} == 0 ]]; then
    dec_vol 5
  else
    dec_vol "${DELTA}"
  fi
}

set_vol() {
  pactl set-sink-volume @DEFAULT_SINK@ "$1%"
  smart_mute
}

toggle_vol() {
  pactl set-sink-mute @DEFAULT_SINK@ toggle
}

mute_vol() {
  pactl set-sink-mute @DEFAULT_SINK@ 1
}

current_volume() {
  pactl list sinks | awk '/Volume: / { print $5 }' | head -n 1
}

smart_mute() {
  if [[ $(current_volume) == 0% ]]; then
    pactl set-sink-mute @DEFAULT_SINK@ 1
  else
    pactl set-sink-mute @DEFAULT_SINK@ 0
  fi
}


case "${1:-}" in
  "inc")
    shift
    if [[ -z ${1:-} ]]; then
      inc_snap
    else
      check_parse "$1"
      inc_vol "$1"
    fi
    ;;
  "dec")
    shift
    if [[ -z ${1:-} ]]; then
      dec_snap
    else
      check_parse "$1"
      dec_vol "$1"
    fi
    ;;
  "set")
    shift
    if [[ -z ${1:-} ]]; then
      echoerr "No percentage provided for set"
      exit 1
    else
      check_parse "$1"
      set_vol "$1"
    fi
    ;;
  "toggle")
    toggle_vol
    ;;
  "mute")
    mute_vol
    ;;
  *)
    echoerr "$1 is not a valid command"
    help_message
    exit 1
esac
