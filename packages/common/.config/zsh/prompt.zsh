# prompt themes
autoload -Uz promptinit
promptinit
# prompt walters
# $vcs_info_msg_0_ <- git branch
# %B <- start bold
# %(?..[%?] ) <- if last exit was 0, nothing, else the code in brackets
# %b <- stop bold
# %n <- username
# @ <- literal @
# %U <- start underline
# %m <- hostname up to the first .
# %u <- stop underline
PROMPT="%F{red}%B%(?..[%?] )%b%f%F{yellow}%n%f%F{green}@%f%U%F{blue}%m%f%u%F{green}>%f "
RPROMPT="%F{green}%~%f"
