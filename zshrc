autoload -Uz compinit promptinit
compinit
promptinit

prompt walters

source /usr/share/doc/pkgfile/command-not-found.zsh

alias pubip="wget http://ipinfo.io/ip -qO -" 
alias gitdir="cd /home/$USER/Documents/Git/"
alias vpnup="sudo systemctl start openvpn-client@client"
alias vpndown="sudo systemctl stop openvpn-client@client"
alias cclip="xclip -selection clipboard"
alias clipp="xclip -selection clipboard -o"
alias weather="curl wttr.in"
alias download="curl -O -L -C -"

# alias backdir="cd /run/media/alev/WesternDrive/backup/ArchRsyncApril21/home/alev"

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
