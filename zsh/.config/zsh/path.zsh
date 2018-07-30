# -U only keeps first of duplicates in arrays
typeset -U path

# zsh scripts
path+=("$HOME/.config/zsh/bin")

# personal binaries
path+=("$HOME/bin")

# local user package binaries
path+=("$HOME/.local/bin")

# node_modules binaries
path+=("$HOME/.local/share/node_modules/bin")
export npm_config_prefix=~/.local/share/node_modules

# gem ruby binaries
if (which ruby 1>/dev/null 2>&1); then 
  path+=("$(ruby -e 'print Gem.user_dir')/bin")
fi
