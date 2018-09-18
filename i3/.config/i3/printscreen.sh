#!/bin/bash
import /tmp/screen.png &&\
  xclip -selection clipboard -t image/png -i /tmp/screen.png
