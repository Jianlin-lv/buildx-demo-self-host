#!/bin/bash
set -ex

IMAGE_TAG=${1:-latest}
DOCKER_REPOSITORY=${2:-jianlin_lv}
DOCKER_REGISTRY=${3:-quay.io}
IMAGE_ARCH=("amd64" "arm64")

GOARCH=$(go env GOARCH)

#cilium-iproute2
docker build --no-cache -t "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-iproute2:${IMAGE_TAG}-${GOARCH}" -f Dockerfile.iproute2 .
docker push "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-iproute2:${IMAGE_TAG}-${GOARCH}"
if [ ${GOARCH} == "amd64" ];then
  docker tag "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-iproute2:${IMAGE_TAG}-${GOARCH}" "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-iproute2:${IMAGE_TAG}"
  docker push "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-iproute2:${IMAGE_TAG}"
fi

#cilium-llvm
docker build --no-cache -t "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-llvm:${IMAGE_TAG}-${GOARCH}" -f Dockerfile.llvm .
docker push "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-llvm:${IMAGE_TAG}-${GOARCH}"
if [ ${GOARCH} == "amd64" ];then
  docker tag "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-llvm:${IMAGE_TAG}-${GOARCH}" "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-llvm:${IMAGE_TAG}"
  docker push "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-llvm:${IMAGE_TAG}"
fi

#cilium/cilium-bpftool
docker build --no-cache -t "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-bpftool:${IMAGE_TAG}-${GOARCH}" -f Dockerfile.bpftool .
docker push "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-bpftool:${IMAGE_TAG}-${GOARCH}"
if [ ${GOARCH} == "amd64" ];then
  docker tag "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-bpftool:${IMAGE_TAG}-${GOARCH}" "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-bpftool:${IMAGE_TAG}"
  docker push "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-bpftool:${IMAGE_TAG}"
fi


<<~
#GOARCH=$(go env GOARCH)
SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]}")

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

docker buildx rm  multi-builder | true
docker buildx create --use --name multi-builder --platform linux/arm64,linux/amd64
#docker buildx build --platform linux/amd64,linux/arm64  --push -f ${SCRIPTS_DIR}/../Dockerfile.bpftool . -t ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-bpftool:${IMAGE_TAG}
#docker buildx build --platform linux/amd64,linux/arm64  --push -f ${SCRIPTS_DIR}/../Dockerfile.iproute2 . -t ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-iproute2:${IMAGE_TAG}
#docker buildx build --platform linux/amd64,linux/arm64  --push -f ${SCRIPTS_DIR}/../Dockerfile.llvm . -t ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-llvm:${IMAGE_TAG}
docker buildx build --platform linux/arm64  --push -f ${SCRIPTS_DIR}/../Dockerfile.llvm . -t ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-llvm:${IMAGE_TAG}


#cilium-llvm
docker build -t "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-llvm:${IMAGE_TAG}-${GOARCH}" -f Dockerfile.llvm .
docker push "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-llvm:${IMAGE_TAG}-${GOARCH}"
if [ ${GOARCH} == "amd64" ];then
  docker tag "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-llvm:${IMAGE_TAG}-${GOARCH}" "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-llvm:${IMAGE_TAG}"
  docker push "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-llvm:${IMAGE_TAG}"
fi

#cilium-iproute2
docker build -t "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-iproute2:${IMAGE_TAG}-${GOARCH}" -f Dockerfile.iproute2 .
docker push "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-iproute2:${IMAGE_TAG}-${GOARCH}"
if [ ${GOARCH} == "amd64" ];then
  docker tag "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-iproute2:${IMAGE_TAG}-${GOARCH}" "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-iproute2:${IMAGE_TAG}"
  docker push "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-iproute2:${IMAGE_TAG}"
fi

#cilium/cilium-bpftool
docker build -t "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-bpftool:${IMAGE_TAG}-${GOARCH}" -f Dockerfile.bpftool .
docker push "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-bpftool:${IMAGE_TAG}-${GOARCH}"
if [ ${GOARCH} == "amd64" ];then
  docker tag "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-bpftool:${IMAGE_TAG}-${GOARCH}" "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-bpftool:${IMAGE_TAG}"
  docker push "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/cilium-bpftool:${IMAGE_TAG}"
fi
!
