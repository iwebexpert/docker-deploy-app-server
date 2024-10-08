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

# Auto-cleaning images if DOCKER_DEPLOY_IMAGES_AUTOCLEAN is enabled
if [ "$DOCKER_DEPLOY_IMAGES_AUTOCLEAN" = "1" ]; then
  echo "Auto-cleaning old images..."

  # Remove all unused images
  docker image prune -a -f

  echo "Removed unused images."
fi

# Pull the Docker image
DOCKER_IMAGE_TAGGED="${DOCKER_IMAGE}:${IMAGE_TAG}"
echo "Pulling Docker image: ${DOCKER_IMAGE_TAGGED}..."
docker pull "${DOCKER_IMAGE_TAGGED}"
echo "Docker image ${DOCKER_IMAGE_TAGGED} pulled successfully."

# Auto-cleaning containers if DOCKER_DEPLOY_CONTAINERS_AUTOCLEAN is enabled
if [ "$DOCKER_DEPLOY_CONTAINERS_AUTOCLEAN" = "1" ]; then
  echo "Auto-cleaning old containers..."

  # Find all exited containers related to the service
  exited_containers=$(docker ps -a --filter "name=${APP_NAME}" --filter "status=exited" -q)

  # Check if there are any exited containers to remove
  if [ -n "$exited_containers" ]; then
    # Remove all exited containers related to the service
    docker rm $exited_containers
    echo "Removed exited containers: $exited_containers"
  else
    echo "No exited containers to remove."
  fi
fi

# Check if Docker is running in swarm mode
SWARM_STATUS=$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null || echo "inactive")

if [ "$SWARM_STATUS" != "active" ]; then
  echo "This node is not a swarm manager."
  echo "Initializing Docker Swarm..."
  docker swarm init
else
  echo "Docker Swarm is already initialized."
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

# Deploy
docker stack deploy --with-registry-auth -c "${SCRIPT_DIR}/docker-compose.yml" "${APP_NAME}"
echo "Deployment complete."
