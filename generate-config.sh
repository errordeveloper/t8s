#!/bin/bash

ROLE="${1}"
VERSION_TAG="${2}"

mkdir -p "/root/.kube"
ln -s "/etc/kubernetes/test-pki/kubeconfig" "/root/.kube/config"

mkdir -p "/opt/cni" "/etc/cni"
ln -s "/etc/kubernetes/cni/bin" "/opt/cni/bin"
ln -s "/etc/kubernetes/cni/net.d" "/etc/cni/"

case "${ROLE}" in
  "master")
    mkdir -p "/etc/kubernetes/manifests"
    jq -n "{}
      | .phase1.cloud_provider=\"fake\"
      | .phase1.cluster_name=\"kubernetes\"
      | .phase2.kubernetes_version=\"${ROLE}-${VERSION_TAG}\"
      | .phase2.docker_registry=\"errordeveloper\"
      | .phase2.image_name=\"hyperquick\"
      | .phase2.service_cluster_ip_range=\"10.16.0.0/12\"
    " > "/etc/kubernetes/master-templates/cluster-config.json"
    for pod in "etcd" "kube-apiserver" "kube-controller-manager" "kube-scheduler" ; do
      printf 'local cfg = import "cluster-config.json"; (import "%s.jsonnet")(cfg)' "${pod}" | \
        jsonnet -J "/etc/kubernetes/master-templates/" - > "/etc/kubernetes/manifests/${pod}.json"
    done
    ;;
  "node")
    cp "/etc/kubernetes/test-pki/kubeconfig" "/etc/kubernetes/kubelet.conf"
    kubectl config --kubeconfig="/etc/kubernetes/kubelet.conf" set-cluster secure-testing \
      --server="https://10.99.0.254:443" \
      --certificate-authority="/etc/kubernetes/test-pki/ca.pem" \
      --embed-certs
    kubectl config --kubeconfig="${user}.conf" set-context test-cluster --cluster="secure-testing"
    kubectl config --kubeconfig="${user}.conf" use-context test-cluster
    ;;
esac
