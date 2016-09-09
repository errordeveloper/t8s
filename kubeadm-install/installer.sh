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
    help)
      echo "You are looking at this because you probably want to learn how to revert what has been done."
      echo
      echo "You first want to stop disable and stop kubelet like this:"
      echo
      echo "> sudo systemctl disable kubelet && sudo systemctl stop kubelet"
      echo
      echo "Next, you can run this to remove all local containers owned by Kubernetes:"
      echo
      echo "> sudo docker rm --force --volumes \$(sudo docker ps --filter label=io.kubernetes.pod.name --all --quiet)"
      echo
      echo "And now you should remove files created by kubeadm simply like this:"
      echo
      echo "> sudo rm -rf /etc/kubernetes"
      echo
      echo "Finally you can uninstall the binaries and configuration files we have installed with this command:"
      echo
      echo "> sudo docker run -v /usr/local:/target errordeveloper/kube-installer uninstall"
      echo
      echo "If you aren't happy, read the code. Anyhow, good luck!"
      exit
    ;;
    uninstall|remove|cleanup)
      echo "Uninstalling..."
      echo
      for i in "${kube_bins[@]}" ; do
        rm -f -v "/target/bin/${i}"
      done
      rm -f -v "/target/lib/systemd/system/kubelet.service"
      for i in "${cni_bins[@]}" ; do
        rm -f -v "/target/lib/cni/bin/${i}"
      done
      echo
      echo "Hope you enjoyed, and see you later!"
      exit
      ;;
    install)
      ;;
    *)
      echo "Usage: sudo docker run -v /usr/local:/target errordeveloper/kube-installer [install|help|uninstall]"
      exit
      ;;
  esac
fi

if ! [ -d "/target" ] ; then
  echo "Please make sure to specify target install direcory, e.g.:"
  echo
  echo "> sudo docker run -v /usr/local:/target errordeveloper/kube-installer"
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

install -v -m 755 -d "/target/lib/cni/bin"
install -v -m 755 -d "/target/etc/cni/net.d"

for i in  "${cni_bins[@]}"; do
  install -v -p -m  755 -t "/target/lib/cni/bin" "${dir}/cni/${i}"
done


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
echo "> sudo kubeadm join --token=<...> --api-server-urls <master-ip-address>"
echo
echo "Have fun, and enjoy!"
exit
