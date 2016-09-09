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

KUBE_VERSION_TAG := $(shell git --git-dir $(KUBE_ROOT)/.git rev-parse --short @)
TAG := "$(shell git rev-parse --short @)-$(KUBE_VERSION_TAG)"

BUILD := "$(KUBE_ROOT)/_output/dockerized/bin/linux/amd64"

IMAGE := "gcr.io/kubeadm/installer"

.PHONY: binaries images clean rebuild

default: images

clean rebuild:
	$(MAKE) -C .. $@ WHAT="cmd/kubectl cmd/kubelet cmd/kubeadm"

images: binaries
	@docker build \
	  --build-arg="VERSION_TAG=$(KUBE_VERSION_TAG)" \
	  --tag="$(IMAGE):$(TAG)" "./"
	@echo "Tagging latest image" \
	  && docker tag "$(IMAGE):$(TAG)" "$(IMAGE):latest" \
		&& docker images "$(IMAGE)" ;
	@rm -f kubelet kubeadm kubectl
	@rm -rf cni

publish: images
	@gcloud docker push "$(IMAGE):$(TAG)"
	@gcloud docker push "$(IMAGE):latest"

binaries:
	@cp "$(BUILD)/kubelet" "./"
	@cp "$(BUILD)/kubeadm" "./"
	@cp "$(BUILD)/kubectl" "./"
	@cp -r "../cni/bin" "./cni"
