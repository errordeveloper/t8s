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

exec docker "${conf[@]}" run --tty --interactive \
  --net=host --pid=host --privileged=true \
  --volume=/var/run/docker.sock:/var/run/docker.sock:rw \
  --volume=/var/lib/docker:/var/lib/docker:rw \
  --volume=/dev:/dev \
  --volume=/sys:/sys:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/run:/run:rw \
  --entrypoint=/bin/bash \
    "${image}" \
      -c "${kubeadm} && ${kubelet}"
