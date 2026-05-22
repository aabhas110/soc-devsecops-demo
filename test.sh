#!/bin/bash

set -e

echo "SOC Test Stage Started"

if command -v python3 >/dev/null 2>&1; then
  python3 -m py_compile app.py
elif command -v python >/dev/null 2>&1; then
  python -m py_compile app.py
else
  echo "Python is not installed in Jenkins container. Skipping Python syntax test."
fi

echo "Basic test completed successfully"