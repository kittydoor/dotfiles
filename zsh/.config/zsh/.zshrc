autoload -Uz compinit promptinit
compinit
promptinit
prompt walters

# zstyle :compinstall filename '/home/kitty/.zshrc'
# 
# 
# # autocompletion
# zstyle ':completion:*' menu select
# setopt COMPLETE_ALIASES

# prompt themes

# zle vi mode
bindkey -v

# source various files
source $ZDOTDIR/path.zsh
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/git.zsh
source $ZDOTDIR/ssh_hosts.zsh
source $ZDOTDIR/ssh.zsh

# distro specific files
DISTRO=$(cat /etc/*-release | grep "^NAME" | cut -d= -f2 | tr -d '"')
if [[ $DISTRO == 'Arch Linux' ]]; then
  source $ZDOTDIR/arch.zsh
fi

# history settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# setopt autocd extendedglob nomatch

# beep is bad, and you should feel bad
# unsetopt beep

# added by travis gem
# [ -f /home/kitty/.travis/travis.sh ] && source /home/kitty/.travis/travis.sh
