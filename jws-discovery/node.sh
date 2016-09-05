#!/bin/bash -ex

cd "$(dirname "${BASH_SOURCE[0]}")"

version_tag() {
  if [ ! "${VERSION_TAG+x}" = "x" ] ; then git --git-dir "${KUBE_ROOT:-../../}/.git" describe; fi
}

conf=($(docker-machine config "hyperquick-${1:-"1"}"))

image="errordeveloper/hyperquick:node-$(version_tag)"

token="e44343.dcc54f526ab6beef"

kubeadm="kubeadm join --token=${token} --api-server-urls=https://10.99.0.254:443"
kubelet="$(docker inspect -f '{{range .Config.Entrypoint}}{{.}} {{end}}' "${image}")"

docker "${conf[@]}" tag "${image}" "errordeveloper/hyperquick:master-$(version_tag)"

docker "${conf[@]}" run --rm \
  --volume=/etc:/host-etc:rw \
  --pid=host --privileged=true \
  --entrypoint=/bin/bash \
    "${image}" \
      -c "
        nsenter --mount=/proc/1/ns/mnt -- umount -v /var/lib/kubelet;
        nsenter --mount=/proc/1/ns/mnt -- rm -rfv /var/lib/kubelet;
        nsenter --mount=/proc/1/ns/mnt -- mkdir -pv /var/lib/kubelet;
        nsenter --mount=/proc/1/ns/mnt -- mount -v --bind /var/lib/kubelet /var/lib/kubelet;
        nsenter --mount=/proc/1/ns/mnt -- mount -v --make-rshared /var/lib/kubelet;
        rm -rfv /host-etc/kubernetes;
        cp -av /etc/kubernetes /host-etc/kubernetes;
      "

exec docker "${conf[@]}" run --tty --interactive \
  --net=host --pid=host --privileged=true \
  --volume=/var/run/docker.sock:/var/run/docker.sock:rw \
  --volume=/var/lib/docker:/var/lib/docker:rw \
  --volume=/dev:/dev \
  --volume=/sys:/sys:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/run:/run:rw \
  --volume=/var/lib/kubelet:/var/lib/kubelet:rw,rshared \
  --volume=/etc/kubernetes:/etc/kubernetes:rw \
  --entrypoint=/bin/bash \
  --env="KUBE_HYPERKUBE_IMAGE=${image}" \
  --env="KUBE_DISCOVERY_IMAGE=${image}" \
    "${image}" \
      -c "${kubeadm} && ${kubelet}"
