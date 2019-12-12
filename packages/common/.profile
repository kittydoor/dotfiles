#!/bin/sh

export TERMINAL='urxvt'
export EDITOR='vim'
export BROWSER='firefox'
export FILE='ranger'
export READER='zathura'

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# path (so that sway can find things in user bin)
export PATH="$PATH:/home/$USER/bin"

# less always intepret control chars
export LESS='-R'

# Sway socket fix
# export SWAYSOCK='$(find /run/user/1000 -name 'sway-ipc.1000.*.sock' | head -n 1)'
