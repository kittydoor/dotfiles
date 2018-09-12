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

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
# Alternative: up-line-or-search, which uses only the first word,
# and doesn't require autoload and zle

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

### history settings
HISTFILE=~/.zsh_history
# HISTSIZE > SAVEHIST because of HIST_EXPIRE_DUPS_FIRST
HISTSIZE=12000 # internal hist size
SAVEHIST=10000 # file hist size
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# setopt autocd extendedglob nomatch

# beep is bad, and you should feel bad
# unsetopt beep

# added by travis gem
# [ -f /home/kitty/.travis/travis.sh ] && source /home/kitty/.travis/travis.sh
