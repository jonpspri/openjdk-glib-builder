#!/bin/sh

set -eu

glibc_version=${ADOPTOPENJDK_GLIBC_VERSION:-2.31}
target_registry=${ADOPTOPENJDK_TARGET_REGISTRY:-adoptopenjdk}

docker build --build-arg GLIBC_VERSION="$glibc_version" \
  -t "$target_registry/openjdk-glibc-builder:${glibc_version}-$(uname -m)" \
  ./builder-image/.

docker push "$target_registry/openjdk-glibc-builder:${glibc_version}-$(uname -m)"
