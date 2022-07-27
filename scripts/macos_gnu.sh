#!/bin/bash

# WIP: Look at todo.txt

set -euo pipefail
if [[ ${DEBUG:-} = 1 ]]; then
  set -o xtrace
fi

PACKAGES=(
	"coreutils"
	"findutils"
	"gnu-tar"
	"gnu-sed"
	"gawk"
	"gnutls"
	"gnu-indent"
	"gnu-getopt"
	"grep"
)

echoerr() {
  >&2 echo -n -e "\e[34m!Error:\e[39m "
  >&2 echo "$@"
}

echo brew install ${PACKAGES[@]}
