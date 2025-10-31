#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

echo "Installing generic dependencies..."

sudo apt update
sudo apt install autossh pdal libpdal-dev python3-venv