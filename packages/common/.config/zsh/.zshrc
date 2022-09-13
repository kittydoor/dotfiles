[[ "$(uname -s)" == Darwin ]] && export LC_ALL=en_US.UTF-8

autoload -Uz compinit
case "$(uname -s)" in
  Linux)
    compinit
    ;;
  Darwin)
    # https://stackoverflow.com/questions/55020408/zsh-compinit-insecure-directories-error-message-on-mac-after-installing-homebr
    compinit -i
    ;;
esac
# Rehash always, so changes to files in PATH are reflected
zstyle ':completion:*' rehash true
# Define where to find .zshrc
zstyle :compinstall filename "$ZDOTDIR/.zshrc"
# Define completion menu style
zstyle ':completion:*' menu select
# Treat alises as distinct commands rather than internally substituting them before completion is attempted. Seems to fix dotfiles alias.
# NO_C_A fixes git commands
# C_A fixes file completion
# TODO: Create issue
setopt COMPLETE_ALIASES

# say no to beep
unsetopt BEEP

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
# Some useful reading
# https://superuser.com/questions/585003/searching-through-history-with-up-and-down-arrow-in-zsh
# https://invisible-island.net/ncurses/ncurses.faq.html#modified_keys
# https://unix.stackexchange.com/questions/551337/zsh-get-terminfo-keys-with-modifiers
# https://unix.stackexchange.com/questions/502175/difference-between-zsh-history-substring-search-and-up-line-or-beginning-search
# https://unix.stackexchange.com/questions/57827/tmux-terminfo-problem-with-zsh-key-bindings
# cat -v can show these codes
# e.g. up arrow = ^[[A = terminfo[kcuu1]
bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
# Alternative: up-line-or-search, which uses only the first word,
# and doesn't require autoload and zle

bindkey '^R' history-incremental-search-backward

# source various files
source $ZDOTDIR/path.zsh
source $ZDOTDIR/prompt.zsh
source $ZDOTDIR/history.zsh
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/functions.zsh
source $ZDOTDIR/git.zsh
source $ZDOTDIR/ssh_hosts.zsh
source $ZDOTDIR/ssh.zsh
source $ZDOTDIR/xdg.zsh

# host specific configuration
if [[ -f $ZDOTDIR/local.zsh ]]; then
  source $ZDOTDIR/local.zsh
fi

# distro specific files
case "$(uname -s)" in
  Linux)
    DISTRO=$(cat /etc/*-release | grep "^NAME" | cut -d= -f2 | tr -d '"')
    ;;
  Darwin)
    DISTRO="Darwin"
    ;;
esac
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

if [[ -f "$HOME/.work/zsh" ]]; then 
  source "$HOME/.work/zsh"
fi

# nix / home-manager
export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}

