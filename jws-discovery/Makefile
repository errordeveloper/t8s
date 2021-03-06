#!/bin/bash

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

KUBE_ROOT := ../../

VERSION_TAG := $(shell git --git-dir $(KUBE_ROOT)/.git describe)

BUILD := "$(KUBE_ROOT)/_output/dockerized/bin/linux/amd64"

IMAGE := "gcr.io/kubeadm/hyperkube"


.PHONY: binaries images clean rebuild

default: images

clean rebuild:
	$(MAKE) -C .. $@ WHAT="cmd/kubectl cmd/hyperkube cmd/kubeadm cmd/kube-discovery"

images: binaries
	@docker build \
	  --build-arg="VERSION_TAG=$(VERSION_TAG)" \
	  --tag="$(IMAGE):$(VERSION_TAG)" "./"
	@echo "Tagging latest image" \
		&& docker tag "$(IMAGE):$(VERSION_TAG)" "$(IMAGE):latest" \
		&& docker tag "$(IMAGE):$(VERSION_TAG)" "errordeveloper/hyperquick:master-$(VERSION_TAG)" \
		&& docker tag "$(IMAGE):$(VERSION_TAG)" "errordeveloper/hyperquick:node-$(VERSION_TAG)" \
		&& docker tag "errordeveloper/hyperquick:node-$(VERSION_TAG)" "errordeveloper/hyperquick:master" \
		&& docker tag "errordeveloper/hyperquick:node-$(VERSION_TAG)" "hyperquick:master" \
		&& docker tag "errordeveloper/hyperquick:node-$(VERSION_TAG)" "errordeveloper/hyperquick:node" \
		&& docker tag "errordeveloper/hyperquick:node-$(VERSION_TAG)" "hyperquick:node" \
		&& docker images "$(IMAGE)" ;
	@rm -f hyperkube kubectl kubeadm kube-discovery
	@rm -rf cni

publish: images
	@gcloud docker push "$(IMAGE):$(VERSION_TAG)"
	@gcloud docker push "$(IMAGE):latest"

binaries:
	@cp -a "../cni" "./"
	@cp "$(BUILD)/hyperkube" "./"
	@cp "$(BUILD)/kubectl" "./"
	@cp "$(BUILD)/kubeadm" "./"
	@cp "$(BUILD)/kube-discovery" "./"
