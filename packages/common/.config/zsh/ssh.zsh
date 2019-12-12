# TODO: Warning: At least on Sway, this file is sourced on the first opened terminal,
# so SSH_AUTH_SOCK isn't set and inherited by default.

# Check if SSH_AUTH_SOCK is not a valid socket
if [[ ! -S "${SSH_AUTH_SOCK}" ]]; then
  # If it is not a valid socket, check if there's an agent_env with a valid socket
  # If it is a valid socket, do nothing

  if [[ -S "$(source ~/.ssh/agent_env > /dev/null; echo $SSH_AUTH_SOCK)" ]]; then
    # If agent_env has valid socket, source it
    source ~/.ssh/agent_env > /dev/null

  else
    # Launch new agent and overwrite agent_env

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
    source ~/.ssh/agent_env > /dev/null
  fi
fi
