#!/bin/bash

set -e

TAG=$1

echo "Building Docker image..."

docker build -t ${IMAGE_NAME}:${TAG} .