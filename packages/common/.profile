#!/bin/sh

# Java fix windows not resizing on window managers
# https://wiki.archlinux.org/title/Java#Gray_window,_applications_not_resizing_with_WM,_menus_immediately_closing
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

# less sane defaults as per git
# https://git-scm.com/docs/git-config#git-config-corepager
export LESS='FRX'

# Browser Configuration
UNAME_OSTYPE="$(uname -s)"
case "${UNAME_OSTYPE}" in
[lL]inux*)
  # Wayland native Firefox
  # (required for hardware video acceleration among other things)
  if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    export MOZ_ENABLE_WAYLAND=1
  fi
  # about:config -> media.ffmpeg.vaapi.enabled = true
  # enhanced-h264ify extension -> block VP9 & AV1
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

# home-manager
if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi
