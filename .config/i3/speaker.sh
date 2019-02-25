#!/bin/bash
set -o xtrace
set -euo pipefail

if ! type pacmd > /dev/null; then
  exit 1
fi

SINKS=$(pacmd list-sinks | awk '/index:/{print $NF}' | tr '\n' ' ')
echo "Sinks: ${SINKS}"

DEFAULT_SINK=$(pacmd list-sinks | awk '/* index:/{print $3}')
echo "Default: ${DEFAULT_SINK}"

CURRENT_SINK_MARKER=false
for sink in ${SINKS} ${SINKS}; do
  if [[ ${CURRENT_SINK_MARKER} = true ]]; then
    NEW_SINK=${sink}
    echo "New default sink: ${NEW_SINK}"
    break
  fi
  if [[ ${DEFAULT_SINK} = ${sink} ]]; then
    echo "DEBUG: Found current sink"
    CURRENT_SINK_MARKER=true
  fi
done;

pacmd set-default-sink ${NEW_SINK}
echo "Set default sink from ${DEFAULT_SINK} to ${NEW_SINK}"

pacmd list-sink-inputs | awk '/index:/{print $2}' | xargs -r -I{} pacmd move-sink-input {} ${NEW_SINK}
echo "Set all sink inputs to ${NEW_SINK}"
