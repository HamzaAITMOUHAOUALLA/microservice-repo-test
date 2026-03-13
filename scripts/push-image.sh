#!/bin/bash

set -e

TAG=$1

echo "Pushing image to Harbor..."

docker push ${IMAGE_NAME}:${TAG}