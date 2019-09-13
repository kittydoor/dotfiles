#!/bin/bash
set -euo pipefail

if [[ -z "${1:-}" ]]; then
  echo 'No dir given'
  exit 1
fi

if ! [[ -d ${1:?} ]]; then
  echo 'Path is not a dir'
  exit 1
fi

if [[ -z ${2:-} ]]; then
  echo 'No prefix given'
  exit 1
fi

find "${1}" -name '.git' -type d -print0 |
  while IFS= read -r -d '' line; do
    DIR=${line%%.git}
    pushd $DIR > /dev/null
    NEW_REMOTE=$(git remote -v | awk '/fetch/ { print $2 }' | sed -n "/git@gitlab.com/s/git@gitlab.com/git@${2}.gitlab.com/p")
    if [[ -n "${NEW_REMOTE}" ]]; then
      git remote set-url origin "${NEW_REMOTE}"
      echo "SUCCESS: $(git remote -v | head -n 1)"
    else
      if [[ -z "$(git remote -v | head -n 1)" ]]; then
        echo "WARN (NO REMOTES ON REPO): $(pwd)"
      else
        echo "WARN (URL NOT DEFAULT): $(git remote -v | head -n 1)"
      fi
    fi
    popd > /dev/null
  done
