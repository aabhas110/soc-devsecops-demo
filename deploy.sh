#!/bin/bash

ENV=$1
SHA=$2

echo "Deploying ${SHA} to ${ENV}"

docker stop soc-dev || true
docker rm soc-dev || true

docker run -d \
  --name soc-dev \
  -p 5001:5000 \
  soc-demo:${BUILD_NUMBER}