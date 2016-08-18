#!/bin/bash

ROLE="${1}"
VERSION_TAG="${2}"

mkdir -p "/opt/cni" "/etc/cni"
ln -s "/etc/kubernetes/cni/bin" "/opt/cni/bin"
ln -s "/etc/kubernetes/cni/net.d" "/etc/cni/"

kubeadm manual bootstrap init-master --listen-ip 10.99.0.254
mkdir -p "/root/.kube"
ln -s -f "/etc/kubernetes/admin.conf" "/root/.kube/config"

case "${ROLE}" in
  "master")
    ;;
  "node")
    rm -rf "/etc/kubernetes/manifests"
    rm -rf "/etc/kubernetes/pki"
    ;;
esac
