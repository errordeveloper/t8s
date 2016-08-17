#!/bin/bash -ex
exec docker exec kubelet kubeadm manual bootstrap init-master --listen-ip 10.99.0.254
