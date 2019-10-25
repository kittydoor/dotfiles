autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
PROMPT="\$vcs_info_msg_0_ ${PROMPT}"
zstyle ':vcs_info:git:*' formats '%b'

### Aliases

alias gs="git status "
alias gco="git checkout "
alias gcm="git commit "
alias ga="git add "
alias gd="git diff "
alias gdc="git diff --cached "
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' "
alias gp="git pull "
alias gpr="git pull --rebase "

### Static Named Directories

hash -d git=~/Documents/Git
mkdir -p ~/Documents/Git
