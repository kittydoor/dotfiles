#!/bin/bash
# shellcheck disable=SC2038
set -euo pipefail

# Store exit codes and exit at the end in order to run all linters
EXIT_CODE=0

# Find bashisms in scripts with shebang #!/bin/sh
find . \( -path './.git' -o -path './deprecated' \) -prune -o -type f -exec awk 'NR==1&&/^#!\/bin\/sh$/{print FILENAME}' {} \; | xargs checkbashisms || EXIT_CODE=1

# Shellcheck all files that start with a shebang of #!/bin/*sh (e.g. sh, bash, zsh)
find . \( -path './.git' -o -path './deprecated' \) -prune -o -type f -exec awk 'NR==1&&/^#!\/bin\/.*sh$/{print FILENAME}' {} \; | xargs shellcheck || EXIT_CODE=1

exit "${EXIT_CODE}"
