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
	@for role in node master ; do \
		docker build \
			--build-arg="ROLE=$${role}" \
			--build-arg="VERSION_TAG=$(VERSION_TAG)" \
			--tag="errordeveloper/hyperquick:$${role}-$(VERSION_TAG)" "./" \
		&& docker tag "errordeveloper/hyperquick:$${role}-$(VERSION_TAG)" "errordeveloper/hyperquick:$${role}" \
		&& docker tag "errordeveloper/hyperquick:$${role}-$(VERSION_TAG)" "hyperquick:$${role}" \
		&& docker images "hyperquick:$${role}" ; \
	done
	@rm -f hyperkube kubectl
	@rm -rf cni

binaries:
	@cp -a "../cni" "./"
	@cp "$(BUILD)/hyperkube" "./"
	@cp "$(BUILD)/kubectl" "./"

test-pki/ca-config.json:
	@jq -n "{} \
	  | .signing.default.expiry=\"8760h\" \
	  | .signing.profiles.kubernetes.expiry=\"8760h\" \
	  | .signing.profiles.kubernetes.usages=[ \"signing\", \"key encipherment\", \"server auth\", \"client auth\"] \
	" > $@

test-pki/ca-csr.json:
	@jq -n "{} \
	  | .CN=\"Kubernetes\" \
	  | .key.algo=\"rsa\" \
	  | .key.size=2048 \
	  | .names[0].C=\"GB\" \
	  | .names[0].L=\"London\" \
	  | .names[0].O=\"Weaveworks Ltd.\" \
	  | .names[0].OU=\"CA\" \
	" > $@

test-pki/kubernetes-csr.json: test-pki/ca-csr.json
	@jq " \
	    .hosts[0]=\"kubernetes\" \
	  | .hosts[1]=\"kubernetes.default\" \
	  | .hosts[2]=\"kubernetes.default.svc\" \
	  | .hosts[3]=\"kubernetes.default.svc.cluster.local\" \
	  | .hosts[4]=\"moby\" \
	  | .hosts[5]=\"10.16.0.1\" \
	  | .hosts[6]=\"10.99.0.254\" \
	  | .hosts[7]=\"127.0.0.1\" \
	" < test-pki/ca-csr.json > $@

create-pki: test-pki/ca-config.json test-pki/ca-csr.json test-pki/kubernetes-csr.json
	@cfssl gencert \
	  -initca \
          test-pki/ca-csr.json \
          | (cd test-pki ; cfssljson -bare ca)
	@cfssl gencert \
	  -ca=test-pki/ca.pem \
	  -ca-key=test-pki/ca-key.pem \
	  -config=test-pki/ca-config.json \
	  -profile=kubernetes \
	  test-pki/kubernetes-csr.json \
	  | (cd test-pki ; cfssljson -bare apiserver)
	@cfssl gencert \
	  -ca=test-pki/ca.pem \
	  -ca-key=test-pki/ca-key.pem \
	  -config=test-pki/ca-config.json \
	  -profile=kubernetes \
	  test-pki/kubernetes-csr.json \
	  | (cd test-pki ; cfssljson -bare admin)

recreate-pki:
	@rm -rf test-pki/ ; mkdir test-pki
	@$(MAKE) create-pki
