#!/bin/bash
set -euo pipefail

ansible-playbook \
  -c local --limit "$(hostname)" \
  playbooks/site.yaml \
  "$@"
