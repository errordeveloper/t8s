#!/bin/bash -ex

rm -vrf "/etc/kubernetes/manifests"
mkdir -vp "/etc/kubernetes/manifests"

cp -v "/etc/kubernetes-pki/ca.pem" "/etc/kubernetes/ca.pem"
< "/etc/kubernetes-pki/tokens.csv" cut -d, -f1 > "/etc/kubernetes/bootsrap-token"
rm -vrf "/etc/kubernetes-pki"
rm -vf "/etc/kubernetes/kubelet.conf"
