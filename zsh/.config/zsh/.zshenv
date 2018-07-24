export EDITOR=vim
export TERMINAL=kitty # for i3-sensible-terminal

if [[ -z "$TMUX" ]]; then
  if [[ -a /usr/share/terminfo/x/xterm-256color ]]; then
    export TERM=xterm-256color;
  else
    export TERM=xterm;
  fi;
fi;
