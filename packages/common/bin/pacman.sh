#!/bin/bash
set -euo pipefail
if [[ ${DEBUG:-} = 1 ]]; then
  set -o xtrace
fi

echoerr() {
  >&2 echo -n -e "\e[34m!Error:\e[39m "
  >&2 echo "$@"
}

# read file path, get the directory name, go up a few steps, and then resolve the relative path
SCRIPT_DIR="$(readlink -m "$(dirname "$(readlink -f "$0")")/../../..")"
STOW_ARGS=("--dir=${SCRIPT_DIR}/packages/" "--target=${HOME}")

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
      echo "Package: $(basename "${dir}")"
      stow "${STOW_ARGS[@]}" "$(basename "$dir")" || true
    else
      echoerr "This should not happen. There is a non-directory file in the packages directory."
      exit 2
    fi
  done
else
  for item in "$@"; do
    if [[ -d "${SCRIPT_DIR}/packages/${item}" ]]; then
      echo "Package: ${1}"
      stow "${STOW_ARGS[@]}" "$item"
    else
      echoerr "Package not found: ${1}"
    fi
  done
fi
