#!/bin/bash
set -euo pipefail

: "${WORKSPACE_DIR:?WORKSPACE_DIR not set}"

echo "Installing generic dependencies..."

sudo apt update
sudo apt install autossh python3-venv

conda install -c conda-forge python-pdal libpdal

echo " 00 Generic dependencies installation completed. ✅ Success"

exit
