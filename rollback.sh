#!/bin/bash

echo "Rollback Triggered"

docker stop soc-dev || true
docker rm soc-dev || true

docker run -d \
  --name soc-dev \
  -p 5001:5000 \
  soc-demo:backup