#!/bin/bash -ex

DOCKER_MACHINE_DRIVER="${DOCKER_MACHINE_DRIVER:-"vmwarefusion"}"

nodes=($(seq "${1:-"1"}"))

for n in "${nodes[@]}" ; do
  docker-machine create --driver="${DOCKER_MACHINE_DRIVER}" "hyperquick-${n}"
  eval "$(docker-machine env --shell bash "hyperquick-${n}")"
  weave launch-router --ipalloc-init=observer
  weave expose "10.99.0.${n}/24"
  eval "$(docker-machine env --shell bash --unset)"
done
