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

FROM debian:8

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -y \
    && apt-get -yy -q install --no-install-recommends --no-install-suggests --fix-missing \
      iptables \
      ethtool \
      ca-certificates \
      conntrack \
      file \
      util-linux \
      socat \
      curl \
      git \
      make gcc g++ \
    && cd /tmp \
    && git clone --quiet --depth 10 https://github.com/google/jsonnet \
    && cd jsonnet \
    && git checkout v0.8.9 -b build \
    && make \
    && cp jsonnet /usr/bin/jsonnet \
    && rm -rf /tmp/jsonnet \
    && curl --silent --location https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 --output /usr/bin/jq \
    && chmod +x /usr/bin/jq \
    && apt-get upgrade -y \
    && apt-get remove -y make gcc g++ \
    && apt-get autoremove -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN ln /usr/bin/nsenter /nsenter
