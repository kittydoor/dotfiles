#!/bin/bash

# Add cgroups_enable=memory
# $ sudo cat /boot/firmware/nobtcmd.txt
# net.ifnames=0 dwc_otg.lpm_enable=0 console=ttyAMA0,115200 console=tty1 root=LABEL=writable rootfstype=ext4 elevator=deadline rootwait fixrtc cgroup_enable=memory

sudo snap install docker
sudo snap install --classic helm

helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo add loki https://grafana.github.io/loki/charts

helm repo update

curl -sfL https://get.k3s.io | sh -

until [ -f /etc/rancher/k3s/k3s.yaml ]; do
  sleep 3
done

mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown kitty:kitty ~/.kube/config
chmod 700 ~/.kube
chmod 600 ~/.kube/config
export KUBECONFIG=~/.kube/config

# helm install jenkins stable/jenkins  # doesn't support arm64

# TODO: quoting of label val seems to get lost
GRAFANA_VALUES="$(cat <<"EOF"
persistence:
  enabled: true

env:
  GF_SERVER_ROOT_URL: https://nyaa-pi4.lan/grafana
  GF_SERVER_DOMAIN: nyaa-pi4.lan
  GF_SERVER_SERVE_FROM_SUB_PATH: true

service:
  labels:
    traefik.enable: true
    traefik.frontend.rule: "Host:nyaa-pi4.lan;PathPrefixStrip:/grafana;"
    traefik.frontend.redirect.entryPoint: "https"
EOF
)"

# https://github.com/helm/helm/issues/7116

TMPFILE=$(mktemp)

echo "$GRAFANA_VALUES" > "$TMPFILE"

helm upgrade --install \
  --values "$TMPFILE" \
  grafana stable/grafana

rm "$TMPFILE"

#  --set ingress.enabled=true \
#  --set ingress.hosts="{nyaa-pi4.lan}" \
#  --set ingress.path=/grafana \
#  --set ingress.annotations."traefik\.frontend\.rule"="Host:nyaa-pi4.lan;PathPrefixStrip: \
#  --set ingress.annotations."traefik\.ingress\.kubernetes\.io/rewrite-target"=/ \
#  --set ingress.annotations."traefik\.ingress\.kubernetes\.io/rule-type"=PathPrefixStrip \

helm upgrade --install \
  --set loki.persistence.enabled=true \
  loki loki/loki-stack
