#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Determine the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Source the .env file to load APP_NAME
if [ ! -f "${SCRIPT_DIR}/.env" ]; then
  echo ".env file not found in ${SCRIPT_DIR}!"
  exit 1
fi

source "${SCRIPT_DIR}/.env"

# Check if IMAGE_TAG is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <IMAGE_TAG>"
  exit 1
fi

# Set the IMAGE_TAG from the first argument
IMAGE_TAG=$1

# Check if APP_NAME is set in the .env file
if [ -z "$APP_NAME" ]; then
  echo "APP_NAME is not set in the .env file!"
  exit 1
fi

# Deploy the stack using docker stack deploy
echo "Deploying ${APP_NAME} with image tag ${IMAGE_TAG} using ${SCRIPT_DIR}/docker-compose.yml..."

export IMAGE_TAG=${IMAGE_TAG}

# Check and export DOCKER_IMAGE if it's non-empty
if [ -n "$DOCKER_IMAGE" ]; then
    export DOCKER_IMAGE
fi

# Check and export APP_INTERNAL_PORT if it's non-empty
if [ -n "$APP_INTERNAL_PORT" ]; then
    export APP_INTERNAL_PORT
fi

# Check and export APP_EXTERNAL_PORT if it's non-empty
if [ -n "$APP_EXTERNAL_PORT" ]; then
    export APP_EXTERNAL_PORT
fi

docker stack deploy -c "${SCRIPT_DIR}/docker-compose.yml" "${APP_NAME}"

echo "Deployment complete."
