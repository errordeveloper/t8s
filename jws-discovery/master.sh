#!/bin/bash -ex

cd "$(dirname "${BASH_SOURCE[0]}")"

weave launch-router || true
weave expose 10.99.0.254/24 || true

version_tag() {
  if [ ! "${VERSION_TAG+x}" = "x" ] ; then git --git-dir "${KUBE_ROOT:-../../}/.git" describe; fi
}

image="errordeveloper/hyperquick:master-$(version_tag)"

token="e44343dcc5f2b6a4a3ff3888bc78506c0085c9b4"

nodes=($(docker-machine ls -q | grep hyperquick || true))

kubelet="$(docker inspect -f '{{range .Config.Entrypoint}}{{.}} {{end}}' "${image}")"

for n in "${nodes[@]}" ; do
  weave connect "$(docker-machine ip "${n}")"
done

docker rm -f kubeadm kubelet || true

docker run --rm \
  --volume=/etc:/host-etc:rw \
  --entrypoint=/bin/bash \
    "${image}" \
      -c "
        rm -rfv /host-etc/kubernetes;
        cp -av /etc/kubernetes /host-etc/kubernetes;
      "

docker run --detach \
  --name=kubeadm \
  --net=host \
  --volume=/etc/kubernetes:/etc/kubernetes:rw \
  --entrypoint=/bin/bash \
    "${image}" \
      -c "
        kubeadm init --token=\$(cat /etc/kubernetes/bootsrap-token) --listen-ip=10.99.0.254;
      "

docker run --rm --tty --interactive \
  --name=kubelet \
  --net=host --pid=host --privileged=true \
  --volume=/var/run/docker.sock:/var/run/docker.sock:rw \
  --volume=/var/lib/docker:/var/lib/docker:rw \
  --volume=/dev:/dev \
  --volume=/sys:/sys:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/etc/kubernetes:/etc/kubernetes:rw \
  --volume=/run:/run:rw \
  --entrypoint=/bin/bash \
    "${image}" \
      -c "
        until ${kubelet}; do sleep 1; done;
      "

docker rm -f kubeadm
