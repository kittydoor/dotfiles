#!/bin/bash
FEDORA_VERSION=$(sed -n '/VERSION_ID=/s/VERSION_ID=//p' /etc/os-release)

sudo dnf install -y gnome-tweaks

dconf write /org/gnome/shell/app-switcher/current-workspace-only true
dconf write /org/gnome/desktop/interface/clock-show-seconds true
dconf write /org/gnome/desktop/interface/clock-show-weekday true
dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
dconf write /org/gnome/desktop/interface/show-battery-percentage true
dconf write /org/gnome/desktop/peripherals/touchpad/tap-to-click true

sudo dnf install -y zsh util-linux-user

sudo chsh -s /bin/zsh ${USER}

git clone --bare https://gitlab.com/kittydoor/dotfiles.git .dotfiles

# alias doesn't work, evaluating instead
# dotfiles="git --git-dir=\"/home/$USER/.dotfiles\" --work-tree=\"/home/$USER\""
# $dotfiles reset --hard  # or checkout?
# $dotfiles config --local status.showUntrackedFiles no

sudo dnf install -y\
  vim-enhanced\
  ranger\
  htop\
  zathura\
  zathura-pdf-mupdf\
  zathura-zsh-completion\
  zathura-bash-completion\
  @virtualization\
  @container-management\
  @vagrant\
  youtube-dl\
  sxiv\
  tldr\
  lshw\
  ShellCheck\
  neovim\
  ncdu\
  ansible

if (( FEDORA_VERSION < 31 )); then
  sudo ln -sf /usr/bin/python3 /usr/bin/python
fi

sudo dnf copr enable -y jdoss/wireguard
sudo dnf install -y wireguard-dkms wireguard-tools

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install -y mpv

sudo dnf distro-sync -y
