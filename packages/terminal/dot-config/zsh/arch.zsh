# source pkgfile for archlinux for suggestions on
# where to find missing binaries
if [[ -d /usr/share/doc/pkgfile ]] then
  source /usr/share/doc/pkgfile/command-not-found.zsh;
fi

# fix view linking to ex
# TODO: add check for vim being installed
alias view="vim -R"

alias kill-orphans='sudo pacman -Rns $(pacman -Qtdq)'
