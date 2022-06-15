#!/bin/sh

# Java fix windows not resizing on window managers
export _JAVA_AWT_WM_NONREPARENTING=1

# https://unix.stackexchange.com/a/213369
# TODO: Consider a function to prefer, in order, multiple options
# by checking which commands are found on system
# TODO: Consider an easy way to "redo" one time checks like this in
# .profile or .zshenv and so on
export TERMINAL='urxvt'
export EDITOR='vim'
export BROWSER='firefox'
export PAGER='less'
export FILE='ranger'
export READER='zathura'

# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# Include user bin folder in path, only after other commands
export PATH="$PATH:/home/$USER/bin"

# less always intepret control chars
export LESS='-R'

# Browser Configuration
if [ "$(uname -s)" != "Darwin" ]; then
  # Hardware video acceleration in Xorg
  export MOZ_X11_EGL=1
  # Wayland native Firefox (also required for hardware video acceleration)
  export MOZ_ENABLE_WAYLAND=1
  # Enable Servo compositor
  export MOZ_WEBRENDER=1
  # about:config -> gfx.webrender.all = true
  # about:config -> media.ffmpeg.vaapi.enabled = true
  # about:config -> media.ffvpx.enabled = false
  # about:config -> media.av1.enabled = false
  # h264ify extension -> block VP9 & AV1
  # Set browser for MacOS
else
  # Python throws a hissyfit if BROWSER is set
  # https://bugs.python.org/issue24955
  # https://github.com/python/cpython/pull/27751
  #export BROWSER="/Applications/Firefox.app/Contents/MacOS/firefox"
  unset BROWSER
fi
