autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '%b '
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
PROMPT="\${vcs_info_msg_0_}${PROMPT}"

### Alias

alias g="git"

### Static Named Directories

# hash -d git=~/Documents/Git
# mkdir -p ~/Documents/Git
