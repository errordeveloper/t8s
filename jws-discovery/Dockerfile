# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM errordeveloper/hyperquick:base

ARG VERSION_TAG

ADD . /etc/kubernetes

RUN /etc/kubernetes/generate-config.sh $VERSION_TAG

ENTRYPOINT [ "/hyperkube", "kubelet", "--network-plugin=cni", "--network-plugin-dir=/etc/cni/net.d", "--kubeconfig=/etc/kubernetes/kubelet.conf", "--require-kubeconfig=true", "--pod-manifest-path=/etc/kubernetes/manifests", "--allow-privileged=true" ]
