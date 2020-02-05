#!/bin/bash

ssh nyaa-pi4.lan bash -s <<EOF
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644

mkdir -p ~/.kube
chmod 700 ~/.kube
ln -s /etc/rancher/k3s/k3s.yaml ~/.kube/config
EOF

scp nyaa-pi4.lan:/etc/rancher/k3s/k3s.yaml ~/.kube/config_pi4

if grep default ~/.kube/config_pi4 > /dev/null; then
  sed -i 's/default/pi4/g' ~/.kube/config_pi4
fi
