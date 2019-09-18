# -U only keeps first of duplicates in arrays
typeset -U path

function addpath {
  if [[ -d $1 ]]; then
    path+=($1)
  fi
}

# zsh scripts
addpath "$HOME/.config/zsh/bin"

# personal binaries
addpath "$HOME/bin"

# local user package binaries
addpath "$HOME/.local/bin"

# node_modules binaries
addpath "$HOME/.local/share/node_modules/bin"
export npm_config_prefix=~/.local/share/node_modules

# krew
addpath "$HOME/.krew/bin"

# gem ruby binaries
if (which ruby 1>/dev/null 2>&1); then
  GEM_USER_DIR="$(ruby -e 'print Gem.user_dir')/bin"
  if [[ -z "$GEM_USER_DIR" ]]; then
    addpath "$GEM_USER_DIR"
  fi
fi
