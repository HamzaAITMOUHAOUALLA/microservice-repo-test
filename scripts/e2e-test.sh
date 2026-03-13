
#!/bin/bash
set -euo pipefail

# ===============================
# Verify required environment variables
# ===============================

: "${CONTAINER_NAME:?CONTAINER_NAME not set}"
: "${STAGING_PORT:?STAGING_PORT not set}"

BASE_URL="http://${CONTAINER_NAME}:8080/api/files"

echo "Starting E2E tests..."

# ===============================
# Wait for application to start
# ===============================

MAX_RETRIES=20
SLEEP_TIME=5

echo "Waiting for application to become ready..."

for i in $(seq 1 $MAX_RETRIES)
do
  if curl -s ${BASE_URL} > /dev/null; then
    echo "Application is ready ✅"
    break
  fi

  echo "Attempt $i/$MAX_RETRIES - application not ready yet..."
  sleep $SLEEP_TIME
done

if ! curl -s ${BASE_URL} > /dev/null; then
  echo "Application failed to start ❌"
  docker logs ${CONTAINER_NAME} || true
  exit 1
fi

# ===============================
# Prepare test file
# ===============================

echo "Creating test file..."
echo "Test file for CI pipeline" > sample.txt

# ===============================
# Upload file
# ===============================

echo "Uploading file..."

curl -s -F "file=@sample.txt" \
     ${BASE_URL}/upload \
     -o upload.json

# ===============================
# Extract fileId from response
# ===============================

FILE_ID=$(jq -r '.fileId' upload.json)

if [ -z "$FILE_ID" ] || [ "$FILE_ID" = "null" ]; then
  echo "Upload failed ❌"
  cat upload.json
  exit 1
fi

echo "File uploaded successfully. ID: $FILE_ID"

# ===============================
# Process file
# ===============================

echo "Processing file..."

curl -s -X POST ${BASE_URL}/process/$FILE_ID

# ===============================
# Download processed file
# ===============================

echo "Downloading processed result..."

curl -s \
     -o result.zip \
     ${BASE_URL}/download/$FILE_ID

# ===============================
# Validate ZIP archive
# ===============================

echo "Validating ZIP file..."

unzip -t result.zip > /dev/null

echo "ZIP file is valid ✅"

# ===============================
# Cleanup
# ===============================

rm -f sample.txt upload.json result.zip

echo "E2E TESTS PASSED ✅"
