#!/bin/bash

VERSION_TAG="${1}"

mkdir -p "/opt/cni" "/etc/cni"
ln -s "/etc/kubernetes/cni/bin" "/opt/cni/bin"
ln -s "/etc/kubernetes/cni/net.d" "/etc/cni/"

env KUBE_HOST_PKI_PATH="/etc/kubernetes-pki" \
  kubeadm manual bootstrap init-master --listen-ip 10.99.0.254 # TODO it should take $VERSION_TAG for testing

# TODO: we should also provide this for the user
mkdir -p "/root/.kube"
ln -s -f "/etc/kubernetes/admin.conf" "/root/.kube/config"
