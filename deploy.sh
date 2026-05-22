#!/bin/bash

set -e

ENV=$1
BUILD_NUMBER_ARG=$2

APP_NAME=${APP_NAME:-soc-demo}
APP_PORT=${APP_PORT:-5001}
CONTAINER_PORT=${CONTAINER_PORT:-5000}
CONTAINER_NAME="${APP_NAME}-${ENV}"
IMAGE_TAG="${APP_NAME}:${BUILD_NUMBER_ARG}"

echo "Deploying application"
echo "Environment: ${ENV}"
echo "Build Number: ${BUILD_NUMBER_ARG}"
echo "App Name: ${APP_NAME}"
echo "Container Name: ${CONTAINER_NAME}"
echo "Image Tag: ${IMAGE_TAG}"
echo "Port Mapping: ${APP_PORT}:${CONTAINER_PORT}"

docker stop "${CONTAINER_NAME}" || true
docker rm "${CONTAINER_NAME}" || true

docker run -d \
  --name "${CONTAINER_NAME}" \
  -p "${APP_PORT}:${CONTAINER_PORT}" \
  --restart unless-stopped \
  "${IMAGE_TAG}"

echo "Deployment completed"
docker ps --filter "name=${CONTAINER_NAME}"
