#!/bin/bash
if [[ -z "${1:-}" ]]; then
  echo "No package names given." > /dev/stderr
  exit 1
fi

stow --dir="packages/" --target="/home/${USER}" --dotfiles -S "$@"
