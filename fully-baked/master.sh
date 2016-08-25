#!/bin/bash -ex

cd "$(dirname "${BASH_SOURCE[0]}")"

weave launch-router || true
weave expose 10.99.0.254/24 || true

version_tag() {
  if [ ! "${VERSION_TAG+x}" = "x" ] ; then git --git-dir "${KUBE_ROOT:-../../}/.git" describe; fi
}

nodes=($(docker-machine ls -q | grep hyperquick || true))

for n in "${nodes[@]}" ; do
  weave connect "$(docker-machine ip "${n}")"
done

exec docker run --tty --interactive --rm --name=kubelet \
  --net=host --pid=host --privileged=true \
  --volume=/var/run/docker.sock:/var/run/docker.sock:rw \
  --volume=/var/lib/docker:/var/lib/docker:rw \
  --volume=/dev:/dev \
  --volume=/sys:/sys:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/run:/run:rw \
  "errordeveloper/hyperquick:master-$(version_tag)" \
      --kubeconfig="/etc/kubernetes/kubelet.conf" \
      --require-kubeconfig=true \
      --config=/etc/kubernetes/manifests "$@"
