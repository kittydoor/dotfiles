#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
. /etc/profile.d/custom-bash-options.sh

HISTCONTROL=ignoredups:erasedups
HISTSIZE=100000
HISTFILESIZE=100000
shopt -s histappend

PATH="$PATH:$HOME/go/bin"
SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
