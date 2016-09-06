#!/bin/bash -eu

kube_bins=(
  "kubelet"
  "kubeadm"
  "kubectl"
)

cni_bins=(
  "cnitool"
  "flannel"
  "tuning"
  "bridge"
  "ipvlan"
  "loopback"
  "macvlan"
  "ptp"
  "dhcp"
  "host-local"
)

if [ "$#" -gt 0 ] ; then
  case "$1" in
    uninstall|remove|cleanup)
      echo "Removing all our files!"
      echo
      for i in "${kube_bins[@]}" ; do
        rm -f -v "/target/bin/${i}"
      done
      rm -f -v "/target/lib/systemd/system/kubelet.service"
      for i in "${cni_bins[@]}" ; do
        rm -f -v "/target/etc/cni/net.d/${i}"
      done
      rm -f -v "/target/etc/cni/net.d/99_bridge.conf"
      echo
      echo "All our files had been removed, what about yours? :)"
      echo "Jokes aside, you might want to check if you still have any containers to cleanup."
      exit
      ;;
  esac
fi

if ! [ -d "/target" ] ; then
  echo "Please make sure to specify target install direcory, e.g.:"
  echo
  echo "> docker run -v /usr/local:/target errordeveloper/kube-installer"
  echo
  echo "Don't give up!"
  exit 1
fi

echo "Installing binaries for Kubernetes (git-${KUBERNETES_BUILD_VERSION}) and systemd configuration..."
echo

dir="/opt/kube-${KUBERNETES_BUILD_VERSION}"

install -v -m 755 -d "/target/bin"
install -v -m 755 -d "/target/lib/systemd/system"

for i in "${kube_bins[@]}" ; do
  install -v -p -m 755 -t "/target/bin" "${dir}/${i}"
done

install -v -p -m 755 -t "/target/lib/systemd/system" "${dir}/kubelet.service"

echo
echo "Installing generic CNI plugins and configuration..."
echo

install -v -m 755 -d "/target/etc/cni/net.d"

for i in  "${cni_bins[@]}"; do
  install -v -p -m  755 -t "/target/etc/cni/net.d" "${dir}/cni/${i}"
done

install -v -p -m  755 -t "/target/etc/cni/net.d" "${dir}/cni/99_bridge.conf"


echo
echo "Binaries and configuration files had been installed, you can now start kubelet and run kubeadm."
echo
echo "> sudo systemctl daemon-reload && sudo systemctl enable kubelet && sudo systemctl start kubelet"
echo
echo "If this host is going to be the master, run:"
echo
echo "> sudo kubeadm init"
echo
echo "If it's going to be a node, run:"
echo
echo "> sudo kubeadm join --token=<...> <master-ip-address>"
echo
echo "Have fun, and enjoy!"
