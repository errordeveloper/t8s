#!/bin/bash -ex

weave launch-router || true
weave expose 10.99.0.254/24 || true

version_tag() {
  if [ ! "${VERSION_TAG+x}" = "x" ] ; then git --git-dir "${KUBE_ROOT:-../}/.git" describe; fi
}

nodes=($(docker-machine ls -q | grep hyperquick))

for n in "${nodes[@]}" ; do
  weave connect "$(docker-machine ip "${n}")"
done

docker run --tty --interactive \
  --volume=/etc:/etc:rw \
  "errordeveloper/hyperquick:base" \
    bash -c 'rm -vrf "/etc/kubernetes-pki" ; mkdir -p "/etc/kubernetes-pki" ; true'

exec docker run --tty --interactive \
  --net=host --pid=host --privileged=true \
  --volume=/var/run/docker.sock:/var/run/docker.sock:rw \
  --volume=/var/lib/docker:/var/lib/docker:rw \
  --volume=/dev:/dev \
  --volume=/sys:/sys:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/etc/kubernetes-pki:/etc/kubernetes/pki:rw \
  --volume=/run:/run:rw \
  "errordeveloper/hyperquick:master-$(version_tag)" \
      --kubeconfig="/etc/kubernetes/kubelet.conf" \
      --wait-for-kubeconfig=true \
      --config=/etc/kubernetes/manifests "$@"
