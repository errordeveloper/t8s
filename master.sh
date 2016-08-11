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

exec docker run --tty --interactive \
  --net=host --pid=host --privileged=true \
  --volume=/var/run/docker.sock:/var/run/docker.sock:rw \
  --volume=/var/lib/docker:/var/lib/docker:rw \
  --volume=/dev:/dev \
  --volume=/sys:/sys:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/run:/run:rw \
  "errordeveloper/hyperquick:master-$(version_tag)" \
      --api-servers=http://127.0.0.1:8080 \
      --config=/etc/kubernetes/manifests "$@"
