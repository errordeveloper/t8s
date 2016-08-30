#!/bin/bash -ex

VERSION_TAG="${1}"

ln -v "/etc/kubernetes/hyperkube" "/hyperkube"
ln -v "/etc/kubernetes/kubectl" "/usr/bin/kubectl"
ln -v "/etc/kubernetes/kubeadm" "/usr/bin/kubeadm"
ln -v "/etc/kubernetes/kube-discovery" "/usr/bin/kube-discovery"

mkdir -vp "/opt/cni" "/etc/cni"
ln -vs "/etc/kubernetes/cni/bin" "/opt/cni/bin"
ln -vs "/etc/kubernetes/cni/net.d" "/etc/cni/"

mkdir -vp "/etc/kubernetes/manifests"

# TODO: we should also provide this for the user
mkdir -vp "/root/.kube"
ln -vsf "/etc/kubernetes/admin.conf" "/root/.kube/config"

( date ; env ; ) | openssl sha1 | cut -d " "  -f "2" > "/etc/kubernetes/bootsrap-token"
