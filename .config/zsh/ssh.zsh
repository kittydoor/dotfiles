# TODO: Implement gnome-keyring and ssh-agent together
# if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]] || ! pgrep -u "$USER" gnome-keyring; then
# ssh-agent stuff
# else, in local session with gnome-keyring running

# start ssh-agent if not running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
  ssh-agent > ~/.ssh/agent
fi

# eval env on new shells
if [[ -z "$SSH_AUTH_SOCK" ]]; then
  eval "$(<~/.ssh/agent)" > /dev/null
fi
