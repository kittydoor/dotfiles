autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
PROMPT=\$vcs_info_msg_0_\ $PROMPT
zstyle ':vcs_info:git:*' formats '%b'


### Static Named Directories

hash -d git=~/Documents/Git
hash -d vmaas=~git/VMaaS
hash -d pod=~/Documents/Podictive

alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
