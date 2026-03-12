#!/bin/bash

set -e

ENV_FILE="config/pipeline.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "pipeline.env not found"
  exit 1
fi

export $(grep -v '^#' $ENV_FILE | xargs)

echo "Pipeline configuration loaded"