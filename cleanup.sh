#!/bin/bash
# cleanup.sh is a script for manually cleaning up unused docker data

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

# Check if APP_NAME is set in the .env file
if [ -z "$APP_NAME" ]; then
  echo "APP_NAME is not set in the .env file!"
  exit 1
fi

# Remove stopped containers
# docker container prune -f
docker rm $(docker ps -a --filter "name=${APP_NAME}" --filter "status=exited" -q)

# Remove unused images
# docker image prune -a -f

# Remove unused volumes
# docker volume prune -f

# Remove unused networks
# docker network prune -f

echo "Cleanup complete."
