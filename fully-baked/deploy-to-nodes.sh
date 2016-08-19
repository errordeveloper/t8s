#!/bin/bash -ex

nodes=($(docker-machine ls -q | grep hyperquick))

version_tag() {
  if [ ! "${VERSION_TAG+x}" = "x" ] ; then git --git-dir "${KUBE_ROOT:-../}/.git" describe; fi
}

docker save -o "node.tar" "errordeveloper/hyperquick:node-$(version_tag)"

for n in "${nodes[@]}" ; do
  eval "$(docker-machine env --shell bash "${n}")"
  make clean 
  docker load -i "node.tar"
  eval "$(docker-machine env --shell bash --unset)"
done

rm -f "node.tar"
