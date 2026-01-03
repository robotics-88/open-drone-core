#!/bin/bash
set -euo pipefail

: "${WORKSPACE_DIR:?WORKSPACE_DIR not set}"

echo "Installing generic dependencies..."

sudo apt-get update
sudo apt-get install -y autossh pdal libpdal-dev python3-venv

echo " 00 Generic dependencies installation completed. ✅ Success"

