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

.PHONY: binaries images clean rebuild

default: images

clean rebuild:
	$(MAKE) -C .. $@

images: binaries
	@docker build \
	  --build-arg="VERSION_TAG=$(VERSION_TAG)" \
	  --tag="errordeveloper/hyperquick:master-$(VERSION_TAG)" "./"
	@printf "FROM errordeveloper/hyperquick:master-$(VERSION_TAG)\nRUN rm -rf /etc/kubernetes/manifests /etc/kubernetes/pki && mkdir -p /etc/kubernetes/manifests" \
		| docker build --tag="errordeveloper/hyperquick:node-$(VERSION_TAG)" -
	@for role in node master ; do echo "Tagging latest $${role} image" \
		&& docker tag "errordeveloper/hyperquick:$${role}-$(VERSION_TAG)" "errordeveloper/hyperquick:$${role}" \
		&& docker tag "errordeveloper/hyperquick:$${role}-$(VERSION_TAG)" "hyperquick:$${role}" \
		&& docker images "hyperquick:$${role}" ; \
	done
	@rm -f hyperkube kubectl kubeadm
	@rm -rf cni

binaries:
	@cp -a "../cni" "./"
	@cp "$(BUILD)/hyperkube" "./"
	@cp "$(BUILD)/kubectl" "./"
	@cp "$(BUILD)/kubeadm" "./"
