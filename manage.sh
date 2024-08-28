#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if the required argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <start|stop>"
  exit 1
fi

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

# Define the scale values based on the start/stop command
if [ "$1" = "start" ]; then
  SCALE_VALUE=2
elif [ "$1" = "stop" ]; then
  SCALE_VALUE=0
else
  echo "Invalid command. Use 'start' or 'stop'."
  exit 1
fi

# Scale the service
echo "Scaling service ${APP_NAME}_app to ${SCALE_VALUE} replicas..."

docker service scale "${APP_NAME}_app=${SCALE_VALUE}"

echo "Service scaled to ${SCALE_VALUE} replicas."
