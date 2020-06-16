#!/bin/bash
set -euo pipefail

help_message() {
  cat <<EOF
usage: $0 <glob> <before> <after> <season> <start>
example: $0 "*.mkv" "Show " " Bluray-1080p.mkv" 1 1
EOF
}

if (( $# != 5 )); then
  echo "Incorrect arguments"
  echo
  help_message
  exit 1
fi

GLOB="$1"
BEFORE="$2"
AFTER="$3"
SEASON="$4"
START="$5"

confirm() {
  read -r -p "Are You Sure? [Y/n] " input

  case "$input" in
    [yY][eE][sS]|[yY])
      return 0
      ;;
    [nN][oO]|[nN])
      echo "Exitting..."
      exit 0
      ;;
    *)
      echo "Invalid input..."
      exit 1
      ;;
  esac
}

FILES_UNSORTED=($GLOB)
IFS=$'\n' FILES=($(printf '%s\n' "${FILES_UNSORTED[@]}" | sort -V))

COUNTER=$(( $START - 1 ))

for file in "${FILES[@]}"; do
  COUNTER=$(( COUNTER + 1 ))
  echo -e "${file}\t->\t${BEFORE}S$(printf '%02d' "${SEASON}")E$(printf '%02d' "${COUNTER}")$AFTER"
done

confirm

COUNTER=$(( $START -1 ))

for file in "${FILES[@]}"; do
  COUNTER=$(( COUNTER + 1 ))
  mv "${file}" "${BEFORE}S$(printf '%02d' "${SEASON}")E$(printf '%02d' "${COUNTER}")$AFTER"
done
