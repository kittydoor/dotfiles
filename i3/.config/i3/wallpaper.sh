#!/bin/bash
if which hsetroot 1>/dev/null 2>&1; then
  hsetroot -solid "#000000"
elif which xsetroot 1>/dev/null 2>&1; then
  xsetroot -solid "#000000"
fi
