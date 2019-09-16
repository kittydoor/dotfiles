if [ $commands[kubectl] ]; then
  # Should be "source <(kubectl completion zsh)", but it fails atm
  eval $(kubectl completion zsh)
fi
