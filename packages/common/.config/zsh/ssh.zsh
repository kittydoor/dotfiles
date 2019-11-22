# Check if SSH_AUTH_SOCK is not a valid socket
if [[ ! -S "${SSH_AUTH_SOCK}" ]]; then
  # Then, launch agent
  # Otherwise, return

  if [[ "${DESKTOP_SESSION}" = gnome ]]; then
    # If running on gnome, use gnome tooling
    gnome-keyring-daemon --start > ~/.ssh/agent_env
    # Gnome doesn't add this line by default
    echo "export SSH_AUTH_SOCK" >> ~/.ssh/agent_env
  else
    # If not running gnome, use universal (for ssh or other de/wm)
    ssh-agent > ~/.ssh/agent_env
  fi

  # Evaluate agent vars after having started an agent
  eval "$(<~/.ssh/agent_env)" > /dev/null
fi