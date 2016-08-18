# t8s: testing (k)8s

This is a slimmed down dev environment for Kubernetes development.

* Assumes a Linux or Mac host with native Docker (or Docker for Mac) running on it.
* Builds binaries and Docker images on the host.
* Uses Docker Machine to create configurable number of "node" VMs.
* Uses Weave Net to simplify networking between host and VMs (particularly for Docker for Mac).

## How to use

[Install Weave Net](https://www.weave.works/docs/net/latest/installing-weave/) and launch it with `weave launch` on your host.

Check `t8s` out *inside* a working directory of `git@github.com:kubernetes/kubernetes`.

```
$ cd Projects/kubernetes
$ git clone git@github.com:errordeveloper/t8s
$ cd t8s
$ make rebuild
$ make
$ DOCKER_MACHINE_DRIVER=virtualbox ./create-nodes.sh
$ ./deploy-to-nodes.sh
```

Now in a different terminal, from the `t8s` directory, run the master kubelet in the foreground:

```
$ ./master.sh
```

When you make a code change to e.g. kubelet or api server and want to deploy it to the master:

```
^C
$ make rebuild
$ ./master.sh
```

To deploy changes to the nodes, which are running in the docker-machine VMs, the following incantation will copy the docker image to the nodes:

```
$ ./deploy-to-nodes.sh
```

To start up a node in the docker-machine VM, run:
```
$ ./node.sh
```
