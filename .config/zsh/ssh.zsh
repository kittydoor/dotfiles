# For other agents: if [[ "$SSH_AUTH_SOCK" == "" ]]; then

# Start ssh agent
if [[ "${DESKTOP_SESSION}" = gnome-DISABLED ]]; then
  #if ! pidof gnome-keyring-daemon > /dev/null; then
    gnome-keyring-daemon --start > ~/.ssh/agent_env
  #fi
else
  if ! pidof ssh-agent > /dev/null; then
    ssh-agent > ~/.ssh/agent_env
  fi
fi

# on new shells
eval "$(<~/.ssh/agent_env)" > /dev/null
# gnome-keyring-daemon doesn't export by default
export SSH_AUTH_SOCK
