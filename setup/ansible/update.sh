#!/bin/bash
set -euo pipefail

help_message() {
  cat<<EOF
Usage: $0 [-h/--help]
          [-n/--host <hostname]
          [-- <passthrough>]

Example: $0 -n <new hostname> -- --tags hostname
EOF
}

POSITIONAL=()

while (( "$#" )); do
  case "$1" in
    -h|--help) # print help and exit
      help_message
      exit
      ;;
    -n|--host) # override hostname detection
      HOSTNAME="${2:?Missing argument}"
      shift 2
      ;;
    --) # passthrough
      shift
      PASSTHROUGH=("$@")
      break
      ;;
    -*) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # positional arguments
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

if [[ -z ${PASSWORD:-} ]]; then
  echo -n "Password: "
  read -rs PASSWORD
  PASSWORD=${PASSWORD:-default}
  echo
fi

passwdfifo() {
  rm -f "${1:?}"
  mkfifo "${1:?}"
  chmod 600 "${1:?}"
  echo "${2:?}" > "${1:?}" &
}

passwdfifo /tmp/ansible-vault "${PASSWORD}"

ansible-playbook \
  --vault-password-file /tmp/ansible-vault \
  -e "ansible_become_pass=${PASSWORD}" \
  -i inv \
  -c local \
  --limit "${HOSTNAME}" \
  site.yaml \
  "${PASSTHROUGH[@]}"
