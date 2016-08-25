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

# PKI assets are located inside of the container, for this test
# to work we need to copy those into the host, so API server and
# KCM pods can mount them
docker run --rm \
  --volume=/etc:/host-etc:rw \
  --entrypoint=/bin/bash \
    "errordeveloper/hyperquick:master-$(version_tag)" \
      -c "
        rm -vrf /host-etc/kubernetes-pki ;
        cp -va /etc/kubernetes-pki /host-etc/kubernetes-pki ;
      "

exec docker run --tty --interactive --rm --name=kubelet \
  --net=host --pid=host --privileged=true \
  --volume=/var/run/docker.sock:/var/run/docker.sock:rw \
  --volume=/var/lib/docker:/var/lib/docker:rw \
  --volume=/dev:/dev \
  --volume=/sys:/sys:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/etc/kubernetes-pki:/etc/kubernetes/pki:rw \
  --volume=/run:/run:rw \
  "errordeveloper/hyperquick:master-$(version_tag)" \
    "$@"
