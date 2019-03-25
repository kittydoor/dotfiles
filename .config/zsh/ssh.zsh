# For other agents: if [[ "$SSH_AUTH_SOCK" == "" ]]; then

# start ssh-agent
if ! pidof ssh-agent > /dev/null; then
  ssh-agent > ~/.ssh/agent_env
fi

# on new shells
eval "$(<~/.ssh/agent_env)" > /dev/null
