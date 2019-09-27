#!/bin/bash
set -euo pipefail
if [[ ${DEBUG:-} = 1 ]]; then
  set -o xtrace
fi

echoerr() {
  echo -n -e "\e[34m!Error:\e[39m " > /dev/stderr
  echo "$@" > /dev/stderr
}

# read file path, get the directory name, go up a few steps, and then resolve the relative path
SCRIPT_DIR="$(readlink -m "$(dirname "$(readlink -f "$0")")/../../..")"
STOW_ARGS=("--dir=${SCRIPT_DIR}/packages/" "--target=/home/${USER}")

help_message() {
  echoerr "No package names given."
  echo 'Use "all" to install all packages.'
  echo
  echo 'Available packages:' > /dev/stderr
  for dir in "${SCRIPT_DIR}"/packages/*; do
    if [[ -d "$dir" ]]; then
      echo "  $(basename "${dir}")"
    fi
  done
}

if [[ -z "${1:-}" ]]; then
  help_message
  exit 1
fi

if [[ "${1}" == "all" ]]; then
  for dir in "${SCRIPT_DIR}"/packages/*; do
    if [[ -d $dir ]]; then
      stow "${STOW_ARGS[@]}" "$(basename "$dir")"
    else
      echo "This should not happen. There is a non-directory file in the packages directory."
      exit 2
    fi
  done
else
  for item in "$@"; do
    if [[ -d "${SCRIPT_DIR}/packages/${item}" ]]; then
      stow "${STOW_ARGS[@]}" "$item"
    fi
  done
fi
