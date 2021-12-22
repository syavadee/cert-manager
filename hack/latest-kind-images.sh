#!/usr/bin/env bash

# Copyright 2021 The cert-manager Authors.
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


set -eu -o pipefail

# source this lib for KIND_IMAGE_REPO
source "devel/lib/lib.sh"

CRANE=crane
TAGS=$(mktemp)

trap 'rm -f -- "$TAGS"' EXIT

if ! which $CRANE >/dev/null 2>&1; then
	echo -e "Couldn't find crane. Try running:\ngo install github.com/google/go-containerregistry/cmd/crane@latest" >&2
	exit 1
fi

function latest_kind_tag () {
	grep -E "^v$1" $TAGS | sort | tail -1
}

$CRANE ls $KIND_IMAGE_REPO > $TAGS

# the TAGS file will now look like:
# ...
# v1.19.4
# v1.19.7
# v1.20.0
# v1.20.2
# v1.20.7
# ...

LATEST_118_TAG=$(latest_kind_tag "1\\.18")
LATEST_119_TAG=$(latest_kind_tag "1\\.19")
LATEST_120_TAG=$(latest_kind_tag "1\\.20")
LATEST_121_TAG=$(latest_kind_tag "1\\.21")
LATEST_122_TAG=$(latest_kind_tag "1\\.22")
LATEST_123_TAG=$(latest_kind_tag "1\\.23")

LATEST_118_DIGEST=$(crane digest $KIND_IMAGE_REPO:$LATEST_118_TAG)
LATEST_119_DIGEST=$(crane digest $KIND_IMAGE_REPO:$LATEST_119_TAG)
LATEST_120_DIGEST=$(crane digest $KIND_IMAGE_REPO:$LATEST_120_TAG)
LATEST_121_DIGEST=$(crane digest $KIND_IMAGE_REPO:$LATEST_121_TAG)
LATEST_122_DIGEST=$(crane digest $KIND_IMAGE_REPO:$LATEST_122_TAG)
LATEST_123_DIGEST=$(crane digest $KIND_IMAGE_REPO:$LATEST_123_TAG)

cat << EOF
# Copyright 2021 The cert-manager Authors.
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

# generated by $0

KIND_IMAGE_SHA_K8S_118=$LATEST_118_DIGEST
KIND_IMAGE_SHA_K8S_119=$LATEST_119_DIGEST
KIND_IMAGE_SHA_K8S_120=$LATEST_120_DIGEST
KIND_IMAGE_SHA_K8S_121=$LATEST_121_DIGEST
KIND_IMAGE_SHA_K8S_122=$LATEST_122_DIGEST
KIND_IMAGE_SHA_K8S_123=$LATEST_123_DIGEST
EOF
