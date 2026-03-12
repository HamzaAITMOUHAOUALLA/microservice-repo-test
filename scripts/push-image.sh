#!/bin/bash

set -e

TAG=$1

echo "Pushing image to Harbor..."

docker push ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:${TAG}