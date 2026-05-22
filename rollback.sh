#!/bin/bash

set -e

APP_NAME=${APP_NAME:-soc-demo}
RESTORE_FILE="/var/jenkins_home/restore-points/${APP_NAME}-last-successful.env"

echo "Rollback Triggered"
echo "Looking for restore point: ${RESTORE_FILE}"

if [ ! -f "${RESTORE_FILE}" ]; then
  echo "No restore point found. Rollback skipped."
  exit 0
fi

echo "Restore point found:"
cat "${RESTORE_FILE}"

source "${RESTORE_FILE}"

echo "Rolling back to last successful build"
echo "Image: ${IMAGE_TAG}"
echo "Container: ${CONTAINER_NAME}"
echo "Port Mapping: ${APP_PORT}:${CONTAINER_PORT}"

docker stop "${CONTAINER_NAME}" || true
docker rm "${CONTAINER_NAME}" || true

docker run -d \
  --name "${CONTAINER_NAME}" \
  -p "${APP_PORT}:${CONTAINER_PORT}" \
  --restart unless-stopped \
  "${IMAGE_TAG}"

echo "Waiting for rollback container startup"
sleep 10

echo "Verifying rollback health"
curl -f "http://172.17.0.1:${APP_PORT}${HEALTH_ENDPOINT}"

echo "Rollback completed successfully"
