#!/bin/bash

set -e

: "${CONTAINER_NAME:?CONTAINER_NAME not set}"
: "${STAGING_PORT:?STAGING_PORT not set}"

BASE_URL="http://${CONTAINER_NAME}:8080/api/files"

echo "Waiting for application..."

for i in $(seq 1 20)
do
  if curl -s ${BASE_URL} > /dev/null; then
    echo "Application ready"
    break
  fi
  sleep 5
done

if ! curl -s ${BASE_URL} > /dev/null; then
  echo "Application did not start"
  exit 1
fi

echo "Test file" > sample.txt

curl -s -F "file=@sample.txt" \
     ${BASE_URL}/upload \
     -o upload.json

FILE_ID=$(jq -r '.fileId' upload.json)

if [ -z "$FILE_ID" ] || [ "$FILE_ID" = "null" ]; then
  echo "Upload failed"
  exit 1
fi

curl -s -X POST ${BASE_URL}/process/$FILE_ID

curl -s -o result.zip ${BASE_URL}/download/$FILE_ID

unzip -t result.zip

echo "E2E SUCCESS"