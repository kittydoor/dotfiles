#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

import /tmp/screen.png &&\
  xclip -selection clipboard -t image/png -i /tmp/screen.png
