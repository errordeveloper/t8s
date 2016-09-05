#!/bin/sh -eu

if ! [ -d "/target" ] ; then
  echo "Please make sure to specify target install direcory, e.g.:"
  echo
  echo "> docker run -v /usr/local:/target errordeveloper/kube-installer"
  echo
  echo "Don't give up!"
  exit 1
fi

echo "Installing binaries for Kubernetes (git-${KUBERNETES_BUILD_VERSION}) and systemd configuration..."

cd "/opt/kube-${KUBERNETES_BUILD_VERSION}"

install -v -m 755 -d "/target/bin"
install -v -m 755 -d "/target/lib/systemd/system"

install -v -p -m 755 -t "/target/bin" "kubelet"
install -v -p -m 755 -t "/target/bin" "kubeadm"
install -v -p -m 755 -t "/target/bin" "kubectl"
install -v -p -m 755 -t "/target/lib/systemd/system" "kubelet.service"

echo "Binaries and systemd configuration had been installed, you can now start kubelet and run kubeadm."
echo
echo "> sudo systemctl daemon-reload && sudo systemctl enable kubelet && sudo systemctl start kubelet"
echo
echo "If this host is going to be the master, run:"
echo
echo "> kubeadm init"
echo
echo "If it's going to be a node, run:"
echo
echo "> kubeadm join --token=<...> <master-ip-address>"
echo
echo "Have fun, and enjoy!"
