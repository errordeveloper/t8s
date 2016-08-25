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

KUBE_ROOT := ../

VERSION_TAG := $(shell git --git-dir $(KUBE_ROOT)/.git describe)

BUILD := "$(KUBE_ROOT)/_output/dockerized/bin/linux/amd64"

.PHONY: base clean rebuild

defailt:
	@echo "Nothing here, please look in subdirs..."
	@for mk in */Makefile ; do echo "- $${mk}" ; done

rebuild:
	@(export KUBE_ROOT=$(KUBE_ROOT) ; $(MAKE) -C $(KUBE_ROOT) clean ; ./quick-build.sh $(WHAT))

clean:
	-@docker ps -a | awk '$$2 !~ /weaveworks/ && $$1 !~ /^CONTAINER$$/ { print $$1 }' | xargs docker rm -f -v 2>/nev/null
	-@docker images | awk '$$1 ~ /none/ { print $$3 }' | xargs docker rmi -f 2>/dev/null
	-@docker images | awk '$$1 ~ /hyperquick$$/ && $$2 ~ /^(node|master)-v/ { print $$3 }' | xargs docker rmi -f 2> /dev/null

base:
	@docker build -t errordeveloper/hyperquick:$@ $@ && docker push errordeveloper/hyperquick:$@
