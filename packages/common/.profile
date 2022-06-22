#!/bin/sh

# Java fix windows not resizing on window managers
export _JAVA_AWT_WM_NONREPARENTING=1

# TODO: Consider an easy way to "redo" one time checks like this in
# .profile or .zshenv and so on
prefer_command() {
  for cmd in "$@"; do
    if command -v "${cmd}" > /dev/null 2>&1; then
      echo "${cmd}"
      break
    fi
  done
}

# https://unix.stackexchange.com/a/213369
TERMINAL="$(prefer_command alacritty urxvt kitty gnome-terminal konsole)" && export TERMINAL
EDITOR="$(prefer_command nvim vim vi)" && export EDITOR
BROWSER="$(prefer_command firefox chromium google-chrome)" && export BROWSER
export PAGER='less'
export FILE='ranger'
export READER='zathura'
export IMAGE_VIEWER='sxiv'

# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"

# Include user bin folder in path, only after other commands
export PATH="${PATH}:/home/${USER}/bin"

# less always intepret control chars
export LESS='-R'

# Browser Configuration
UNAME_OSTYPE="$(uname -s)"
case "${UNAME_OSTYPE}" in
[lL]inux*)
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
  ;;
[dD]arwin*)
  # Python throws a hissyfit if BROWSER is set
  # https://bugs.python.org/issue24955
  # https://github.com/python/cpython/pull/27751
  #export BROWSER="/Applications/Firefox.app/Contents/MacOS/firefox"
  unset BROWSER
  ;;
*)
  echo ".profile: Unknown 'uname -s'=${UNAME_OSTYPE}"
  ;;
esac
