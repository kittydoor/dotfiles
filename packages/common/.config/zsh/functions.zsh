genpass () {
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c ${1:-48}
  echo
}

ranger() {
  if [[ -z "${RANGER_LEVEL}" ]]; then
    command ranger "$@"
  else
    exit
  fi
}

ORIG_PROMPT="${PROMPT}"
ORIG_RPROMPT="${RPROMPT}"
zsh-presentation-mode() {
  if [[ -z "${ZSH_PRESENTATION_MODE}" ]]; then
    ZSH_PRESENTATION_MODE=1
    PROMPT="$ "
    RPROMPT=""
  else
    ZSH_PRESENTATION_MODE=""
    PROMPT="${ORIG_PROMPT}"
    RPROMPT="${ORIG_RPROMPT}"
  fi
}
