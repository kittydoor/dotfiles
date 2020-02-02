#!/bin/bash
set -e

ansible-playbook \
  -i alarmpi.lan, \
  -e 'ansible_ssh_pass=alarm' \
  pi4_arch_init.yaml
