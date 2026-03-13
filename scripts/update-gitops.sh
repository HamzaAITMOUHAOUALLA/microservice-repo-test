#!/bin/bash

set -e

IMAGE_TAG=$1
ENVIRONMENT=$2

echo "Cloning GitOps repository..."
rm -rf gitops-K8S
rm -rf gitops
rm -rf gitops-repo

git clone https://${GIT_USER}:${GIT_PASS}@${GITOPS_REPO} gitops

cd gitops/${ENVIRONMENT}/${IMAGE_NAME}

echo "Updating image tag..."

sed -i "s|image:.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|g" deployment.yaml

git config user.name "jenkins-bot"
git config user.email "jenkins@company.com"

git add deployment.yaml
git commit -m "Deploy ${IMAGE_NAME}:${IMAGE_TAG} to ${ENVIRONMENT}"

git push

echo "GitOps updated"