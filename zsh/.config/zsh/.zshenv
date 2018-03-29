# custom scripts or binaries
PATH="$PATH:$HOME/.local/bin"
# node_modules
PATH="$PATH:$HOME/.local/share/node_modules/bin"
export npm_config_prefix=~/.local/share/node_modules
# gem
PATH="$PATH:$(ruby -e 'print Gem.user_dir')/bin"

export EDITOR=vim
