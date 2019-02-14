My dotfiles (assumes Arch Linux)

To install:
  git clone --bare git@gitlab.com:kittydoor/dotfiles.git .dotfiles
  alias dotfiles="git --git-dir=\"/home/$USER/.dotfiles\" --work-tree=\"/home/$USER\""

  # if this command fails, you might have to manually remove the conflicting files
  dotfiles checkout

  # if you wish to hide all the untracked files in home
  dotfiles config --local status.showUntrackedFiles no
