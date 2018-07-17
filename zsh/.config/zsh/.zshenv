export EDITOR=vim
export TERMINAL=kitty # for i3-sensible-terminal

export TERM=xterm
if [[ -z "$TMUX" ]]; then
  if [[ -a /usr/share/terminfo/x/xterm-kitty ]]; then
    export TERM=xterm-kitty;
  else
    export TERM=xterm;
  fi;
fi;
