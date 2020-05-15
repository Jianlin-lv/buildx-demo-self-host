#!/bin/bash
set -ex

IMAGE_NAME=${1:-}
IMAGE_TAG=${2:-latest}
DOCKER_REPOSITORY=${3:-cilium}
DOCKER_REGISTRY=${4:-quay.io}
IMAGE_ARCH=("amd64" "arm64")

export DOCKER_CLI_EXPERIMENTAL=enabled

function using_help() {
  echo "Please specify a image name!"
  echo -e "\nUsage::\n\tdocker_manifest.sh IMAGE_NAME [IMAGE_TAG] [DOCKER_REPOSITORY] [DOCKER_REGISTRY]"
  echo -e "\nExample::\n\tdocker_manifest.sh cilium-runtime latest"
  exit 1
}

if [ -z "${IMAGE_NAME}" ]
then
  using_help
fi

MANIFESTS=""

# check image in registry
for arch in "${IMAGE_ARCH[@]}"
do
  if docker manifest inspect ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}-${arch} >/dev/null; then
    echo "Image ${IMAGE_NAME}:${IMAGE_TAG}-${arch} is ready."
    MANIFESTS="${MANIFESTS} ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}-${arch}"
  else
    echo "Please build and push ${IMAGE_NAME}:${IMAGE_TAG}-${arch}."
    exit 0
  fi
done

docker manifest create --amend ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG} ${MANIFESTS}

for arch in ${IMAGE_ARCH}
do
  docker manifest annotate ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG} \
	  ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}-${arch} \
	  --os linux --arch ${arch}
done

docker manifest push ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}
