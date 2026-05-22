#!/bin/bash

set -e

echo "SOC Test Stage Started"

python -m py_compile app.py

echo "Python syntax check passed"
echo "SOC Test Stage Completed"
