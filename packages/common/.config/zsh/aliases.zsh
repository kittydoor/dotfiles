### Generic Aliases
# ZSH expands ls in following aliases
if (which exa 1>/dev/null 2>&1); then
  alias ls="exa --color=auto"
  alias tree="ls --tree"
else
  alias ls="ls --color=auto"
fi
alias ll="ls -al"
alias l.="ls -d .*"

### Ease of Use Commands
alias pubip="wget https://duckduckgo.com/ip -qO - | grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}'"
#alias pubip="wget https://duckduckgo.com/ip -qO - | grep -oE '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*'"
#alias pubip="wget http://ipinfo.io/ip -qO -"
#alias pubip="wget ident.me -qO - && echo" # ident.me doesn't return newline
alias download="curl -O -L -C -"
alias cclip="xclip -selection clipboard"
alias clipp="xclip -selection clipboard -o"

### Fix VIM on fedora
if type vimx > /dev/null; then
  alias vim="vimx"
fi

### Shortcut names
alias doco="docker-compose"

### VPN
alias vpnup="sudo systemctl start openvpn-client@client"
alias vpndown="sudo systemctl stop openvpn-client@client"

### Cool websites
alias weather="curl wttr.in/amsterdam"
alias badhorse="traceroute bad.horse"
alias telnetwars="telnet towel.blinkenlights.nl"
alias cryptorate="curl rate.sx"

# alias backdir="cd /run/media/alev/WesternDrive/backup/ArchRsyncApril21/home/alev"

function session () {
  if [ -z $1 ]; then
    tmux list-sessions
  else
    tmux new -As $1
  fi
}

function ansible-update () {
  if [ -z $1 ]; then
    ansible-playbook -vv -b --ask-become-pass --user pod-adm-kpa -i test site.yml
  else
    ansible-playbook -vv -b --ask-become-pass --user pod-adm-kpa -i test site.yml -t $1
  fi
}

# this function will take local, remote, or other commands,
# in order to use different flags
# example local doesn't have compression
# while remote does
#function backup () {
#  if [ -z $1 ]; then
#    1="--help"
#  else if [
#  fi
#}
alias backup="rsync --archive --verbose --partial --progress"
#alias backup="rsync -avP"

alias browser="firefox-developer-edition"
alias editor="vim"

# Disabled, as switched back to stow
# alias dotfiles="git --git-dir=\"$HOME/.dotfiles\" --work-tree=\"$HOME\""

alias sourcerc="source $ZDOTDIR/.zshrc"
alias fix-i3sock="export I3SOCK=\$(DISPLAY=:0 i3 --get-socketpath)"

function k8s-nodes () {
  if [ -n "${1}" ]; then
    kubectl --context="${1}" get nodes -ojsonpath='{range .items[*]}{.metadata.name}{" "}{.status.addresses[0].address}{"\n"}{end}'
  fi
}

alias gdb="gdb -q"

alias please='sudo $(fc -ln -1)'

alias socks="ssh -D 8080 nyaa-link.lan"

alias please='sudo $(fc -ln -1)'
