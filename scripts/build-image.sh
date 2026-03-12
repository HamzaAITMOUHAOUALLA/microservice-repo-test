#!/bin/bash

set -e

TAG=$1

echo "Building Docker image..."

docker build -t ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:${TAG} .