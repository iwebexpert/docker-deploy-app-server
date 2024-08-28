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

# Check if APP_NAME is set in the .env file
if [ -z "$APP_NAME" ]; then
  echo "APP_NAME is not set in the .env file!"
  exit 1
fi

docker service update --rollback "${APP_NAME}_app"

# Check if the rollback was successful
if [ $? -eq 0 ]; then
  echo "Rollback of ${APP_NAME}_app successful!"
else
  echo "Rollback failed!"
  exit 1
fi
