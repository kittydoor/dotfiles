autoload -Uz compinit
compinit
# Rehash always, so changes to files in PATH are reflected
zstyle ':completion:*' rehash true

autoload -Uz promptinit
promptinit
prompt walters

unsetopt BEEP

# zstyle :compinstall filename '/home/kitty/.zshrc'
# 
# 
# # autocompletion
# zstyle ':completion:*' menu select
# setopt COMPLETE_ALIASES

# prompt themes

# zle vi mode
bindkey -v

# esc v for edit command in vim
autoload -U edit-command-line
zle -N edit-command-line
# maybe bindkey -M
bindkey -M vicmd v edit-command-line

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
source $ZDOTDIR/functions.zsh
source $ZDOTDIR/git.zsh
source $ZDOTDIR/ssh_hosts.zsh
source $ZDOTDIR/ssh.zsh
source $ZDOTDIR/history.zsh

# distro specific files
DISTRO=$(cat /etc/*-release | grep "^NAME" | cut -d= -f2 | tr -d '"')
if [[ $DISTRO == 'Arch Linux' ]]; then
  source $ZDOTDIR/arch.zsh
fi

# setopt autocd extendedglob nomatch

# beep is bad, and you should feel bad
# unsetopt beep

# added by travis gem
# [ -f /home/kitty/.travis/travis.sh ] && source /home/kitty/.travis/travis.sh

# sudo du --exclude /run/media/kitty --exclude /proc -h -d 2 /var | sort -h | less

# Source completion.d
for file in $ZDOTDIR/completion.d/*; do
  source $file || echo "$file failed, ignoring..."
done

export KUBECONFIG=/home/kitty/.kube/config_dev:/home/kitty/.kube/config_prod
