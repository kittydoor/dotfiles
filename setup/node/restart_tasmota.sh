#!/bin/bash
set -euo pipefail

for item in plug_{alpha,beta,charlie,delta} light_bedroom; do
  echo "Restarting $item"
  curl -s "http://${item}.lan/?rst=" > /dev/null || true
done
