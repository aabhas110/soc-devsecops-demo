#!/bin/bash

set -e

echo "SOC Build Stage Started"

if [ -f requirements.txt ]; then
  echo "requirements.txt found"
else
  echo "requirements.txt not found"
  exit 1
fi

if [ -f app.py ]; then
  echo "app.py found"
else
  echo "app.py not found"
  exit 1
fi

echo "SOC Build Stage Completed"
