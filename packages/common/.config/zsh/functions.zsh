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
