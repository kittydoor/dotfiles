autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
PROMPT=\$vcs_info_msg_0_\ $PROMPT
zstyle ':vcs_info:git:*' formats '%b'

### Aliases

alias gs="git status"
alias gc="git checkout"
alias gco="git commit"
alias gd="git diff"

### Static Named Directories

hash -d git=~/Documents/Git
hash -d pod=~git/podictive
hash -d vmaas=~git/podictive/vmaas
hash -d poddoc=~/Documents/Podictive

alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
