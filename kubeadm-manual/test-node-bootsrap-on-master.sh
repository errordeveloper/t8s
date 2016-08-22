#!/bin/bash -x
docker exec -t -i kubelet bash -x -c \
  'kubeadm manual bootstrap join-node --ca-cert-file=/etc/kubernetes/pki/ca.pem --token=$(cat /etc/kubernetes/pki/tokens.csv | cut -d, -f1) --api-server-urls https://10.99.0.254:443'
