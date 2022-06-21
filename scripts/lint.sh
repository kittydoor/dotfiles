#!/bin/bash
set -euo pipefail

# Find bashisms in scripts with shebang #!/bin/sh
find . -path './.git' -prune -o -type f -exec awk 'NR==1&&/^#!\/bin\/sh$/{print FILENAME}' {} \; | xargs checkbashisms

# Shellcheck all files that start with a shebang of #!/bin/*sh (e.g. sh, bash, zsh)
find . -path './.git' -prune -o -type f -exec awk 'NR==1&&/^#!\/bin\/.*sh$/{print FILENAME}' {} \; | xargs shellcheck
