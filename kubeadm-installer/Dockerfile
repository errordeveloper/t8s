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

FROM alpine:latest

ARG VERSION_TAG

ENV KUBERNETES_BUILD_VERSION=${VERSION_TAG}
ADD . /opt/kube-${VERSION_TAG}
WORKDIR /opt/kube-${VERSION_TAG}


# As a basic way to verify we have all the files, we simulate installer run during the build
# (we seem to need sync here, otherwise we get "Text file busy" for some reason)
RUN apk update && apk add bash \
  && ln /opt/kube-${VERSION_TAG}/installer.sh /usr/bin/kube-installer \
  && sync && mkdir /target && /usr/bin/kube-installer && rm -rf /target

ENTRYPOINT [ "/usr/bin/kube-installer" ]
