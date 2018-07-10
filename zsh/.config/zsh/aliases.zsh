### Generic Aliases
# ZSH expands ls in following aliases
if (which exa 1>/dev/null 2>&1); then
  alias ls="exa --color=auto"
else
  alias ls="ls --color=auto"
fi
alias ll="ls -al"
alias l.="ls -d .*"

### Ease of Use Commands
alias session="tmux new -As "
alias pubip="wget http://ipinfo.io/ip -qO -" 
alias download="curl -O -L -C -"
alias cclip="xclip -selection clipboard"
alias clipp="xclip -selection clipboard -o"

### VPN
alias vpnup="sudo systemctl start openvpn-client@client"
alias vpndown="sudo systemctl stop openvpn-client@client"

### Cool websites
alias weather="curl wttr.in"
alias badhorse="traceroute bad.horse"
alias telnetwars="telnet towel.blinkenlights.nl"
alias cryptorate="curl rate.sx"

# alias backdir="cd /run/media/alev/WesternDrive/backup/ArchRsyncApril21/home/alev"
