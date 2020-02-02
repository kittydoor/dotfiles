#!/bin/bash
if [[ -z $VAULT_PASS ]]; then
  echo -n "Vault pass: " 1>&2
  read -rs VAULT_PASS
fi

echo "$VAULT_PASS"
