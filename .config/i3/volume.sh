#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

if ! which pactl 1>/dev/null 2>&1 ; then
  exit 1
fi;

log="volume.sh"
if [[ $1 == "toggle" ]]; then
  log+=" toggling mute"
  pactl set-sink-mute @DEFAULT_SINK@ toggle
  echo -e $log;
  exit
elif [[ $1 == "inc" ]]; then
  log+=" incrementing by"
elif [[ $1 == "dec" ]]; then
  log+=" decrementing by"
else
  log="Error. Incorrect arguments."
  exit 2;
fi;

if [[ $2 =~ ^[1-9][0-9]?$ ]]; then
  log+=" $2%\n"
else
  exit 2;
fi;

pactl set-sink-mute 0 false
if [[ $1 == "inc" ]]; then
  pactl set-sink-volume @DEFAULT_SINK@ "+$2%"
elif [[ $1 == "dec" ]]; then
  pactl set-sink-volume @DEFAULT_SINK@ "-$2%"
fi;

echo -e $log;
