zstyle :compinstall filename '/home/kitty/.zshrc'

autoload -Uz compinit promptinit

# autocompletion
compinit
zstyle ':completion:*' menu select
setopt COMPLETE_ALIASES

# prompt themes
promptinit
prompt walters

# zle vi mode
bindkey -v
# get distro identifier
DISTRO=$(cat /etc/*-release | grep "^NAME" | cut -d= -f2 | tr -d '"')
if [[ $DISTRO == 'Arch Linux' ]]; then
  # source pkgfile for archlinux for suggestions on
  # where to find missing binaries
  if [[ -d /usr/share/doc/pkgfile ]] then
    source /usr/share/doc/pkgfile/command-not-found.zsh;
  fi
  # fix view linking to ex
  # TODO: add check for vim being installed
  alias view="vim -R"
fi

# start ssh-agent
if ! (pgrep -u "$USER" ssh-agent > /dev/null); then
  ssh-agent > ~/.ssh-agent.env
  if [[ -f ~/.ssh/id_rsa_github  ]] then
    eval "$(<~/.ssh-agent.env)" > /dev/null
    ssh-add ~/.ssh/id_rsa_github
  fi
fi

# on new shells
if [[ "$SSH_AGENT_PID" == "" ]]; then
  eval "$(<~/.ssh-agent.env)" > /dev/null
fi

# source aliases
source ~/.config/zsh/.zsh_aliases

# go through all folders in $gitdir and fetch + status
function gitdircheck {
  returndir=`pwd`
  gitdir;
  for dir in */; do
    cd $dir;
    printf '%48s\n' | tr ' ' -;
    echo $dir;
    git fetch;
    git status;
    cd ..;
  done
  cd $returndir
}

function gitdirpull {
  returndir=`pwd`
  gitdir;
  for dir in */; do
    cd $dir;
    printf '%48s\n' | tr ' ' -;
    echo $dir;
    git pull;
    cd ..;
  done
  cd $returndir
}

function gitdirclean {
  returndir=`pwd`
  gitdir;
  for dir in */; do
    cd $dir;
    printf '%48s\n' | tr ' ' -;
    echo $dir;
    git clean -xi;
    cd ..;
  done
  cd $returndir
}

function git-ssh {
  eval $(ssh-agent)
  ssh-add ~/.ssh/id_rsa_github
}


# history settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt autocd extendedglob nomatch

# beep is bad, and you should feel bad
unsetopt beep

# added by travis gem
[ -f /home/kitty/.travis/travis.sh ] && source /home/kitty/.travis/travis.sh
