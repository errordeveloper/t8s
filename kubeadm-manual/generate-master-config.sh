#!/bin/bash -ex

VERSION_TAG="${1}"

ln -v "/etc/kubernetes/hyperkube" "/hyperkube"
ln -v "/etc/kubernetes/kubectl" "/usr/bin/kubectl"
ln -v "/etc/kubernetes/kubeadm" "/usr/bin/kubeadm"

mkdir -vp "/opt/cni" "/etc/cni"
ln -vs "/etc/kubernetes/cni/bin" "/opt/cni/bin"
ln -vs "/etc/kubernetes/cni/net.d" "/etc/cni/"

env KUBE_HOST_PKI_PATH="/etc/kubernetes-pki" \
  kubeadm manual bootstrap init-master --listen-ip 10.99.0.254 # TODO it should take $VERSION_TAG for testing

# TODO: we should also provide this for the user
mkdir -vp "/root/.kube"
ln -vsf "/etc/kubernetes/admin.conf" "/root/.kube/config"
