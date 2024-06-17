# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=50000
SAVEHIST=50000
setopt extendedglob nomatch notify
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/kitty/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

path+=(
  "$HOME/go/bin"
  "$HOME/bin"
)
export PATH

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

autoload -U promptinit
promptinit
prompt suse

. "$HOME/.rye/env"

fortune && echo

function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

alias g="git"

bindkey -v
bindkey ^R history-incremental-search-backward
bindkey ^S history-incremental-search-forward
