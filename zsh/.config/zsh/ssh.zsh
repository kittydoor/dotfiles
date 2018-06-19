# start ssh-agent
if ! (pidof ssh-agent > /dev/null); then
  ssh-agent > ~/.ssh-agent.env
  if [[ -f ~/.ssh/id_rsa_github  ]] then
    eval "$(<~/.ssh-agent.env)" > /dev/null
  fi
fi

# on new shells
if [[ "$SSH_AGENT_PID" == "" ]]; then
  eval "$(<~/.ssh-agent.env)" > /dev/null
fi
