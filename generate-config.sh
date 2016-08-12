#!/bin/bash

ROLE="${1}"
VERSION_TAG="${2}"

kubelet_token="d661098e78bda3d67a74f1012c035f3cbba865eb"

mkdir -p "/opt/cni" "/etc/cni"
ln -s "/etc/kubernetes/cni/bin" "/opt/cni/bin"
ln -s "/etc/kubernetes/cni/net.d" "/etc/cni/"

kubectl config set-cluster secure-testing \
  --server="https://10.99.0.254:443" \
  --certificate-authority="/etc/kubernetes/test-pki/ca.pem" \
  --embed-certs
kubectl config set-credentials admin \
  --client-certificate="/etc/kubernetes/test-pki/admin.pem" \
  --client-key="/etc/kubernetes/test-pki/admin-key.pem" \
  --embed-certs
kubectl config set-context test-cluster \
  --cluster="secure-testing" \
  --user="admin"
kubectl config use-context test-cluster

case "${ROLE}" in
  "master")
    mkdir -p "/etc/kubernetes/manifests"
    echo "${kubelet_token},kubelet,kubelet" > "/etc/kubernetes/tokens"
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
    kubectl config --kubeconfig="/etc/kubernetes/kubelet.conf" set-cluster secure-testing \
      --server="https://10.99.0.254:443" \
      --certificate-authority="/etc/kubernetes/test-pki/ca.pem" \
      --embed-certs
    kubectl config --kubeconfig="/etc/kubernetes/kubelet.conf" set-credentials kubelet \
      --token="${kubelet_token}"
    kubectl config --kubeconfig="/etc/kubernetes/kubelet.conf" set-context test-cluster \
      --cluster="secure-testing" \
      --user="kubelet"
    kubectl config --kubeconfig="/etc/kubernetes/kubelet.conf" use-context test-cluster
    ;;
esac
