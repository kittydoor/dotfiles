# -U only keeps first of duplicates in arrays
typeset -U path

# https://stackoverflow.com/questions/11530090/adding-a-new-entry-to-the-path-variable-in-zsh
# TODO: Does this break on paths with spaces?
function prefixpath {
  if [[ -d "$1" ]] && ! [[ ":$PATH:" == *":$1:"* ]]; then
    path=("$1" $path)
  fi
}

function addpath {
  if [[ -d "$1" ]] && ! [[ ":$PATH:" == *":$1:"* ]]; then
    path+=("$1")
  fi
}

# Darwin/MacOS Specific Paths
if [[ "$(uname -s)" == "Darwin" ]]; then
  # gnu coreutils on Darwin
  [[ ! -d /usr/local/opt/coreutils/libexec/gnubin ]] && echo "coreutils missing. Please run 'brew install coreutils'"
  prefixpath "/usr/local/opt/coreutils/libexec/gnubin"

  # python on Darwin
  # TODO: Fix issue when none exists 'zsh no match'
  # for dir in "$HOME"/Library/Python/*/bin; do
  #   addpath "$dir"
  # done

  # brew casks
  if ! type brew > /dev/null; then
    echo "brew missing. Please install brew from brew.sh"
  else
    # gcloud sdk
    # source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
    # source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
  fi
fi

# zsh scripts
addpath "$HOME/.config/zsh/bin"

# personal binaries
addpath "$HOME/bin"

# local user package binaries
addpath "$HOME/.local/bin"

# golang binaries
if which go 1>/dev/null 2>&1; then
  addpath "$(go env GOPATH)/bin"
fi

# node_modules binaries
addpath "$HOME/.local/share/node_modules/bin"
export npm_config_prefix=~/.local/share/node_modules

# cargo binaries
addpath "$HOME/.local/share/cargo/bin"

# krew
addpath "$HOME/.krew/bin"

# gem ruby binaries
if which ruby 1>/dev/null 2>&1 && which gem >/dev/null 2>&1; then
  addpath "$(ruby -r rubygems -e 'puts Gem.user_dir')/bin"
fi
