#!/bin/sh

export TERMINAL='st'
export EDITOR='vim'
export BROWSER='firefox-developer-edition'
export FILE='ranger'
export READER='zathura'

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# less always intepret control chars
export LESS='-R'

# Sway socket fit
export SWAYSOCK=$(find /run/user/1000 -name 'sway-ipc.1000.*.sock' | head -n 1)
