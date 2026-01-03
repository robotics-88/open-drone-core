#!/bin/bash
set -euo pipefail
: "${WORKSPACE_DIR:?WORKSPACE_DIR not set}"

# Clone rest API
cd $WORKSPACE_DIR/
if [ -d "open-drone-server" ]; then
    echo "Directory open-drone-server already exists. Skipping clone."
else
    git clone -b fix/rclpy_install https://github.com/robotics-88/open-drone-server.git
fi
cd open-drone-server
git pull
python3 -m venv .env
source .env/bin/activate
pip install -r requirements.txt
deactivate

echo "04 Open Drone Server setup completed. ✅ Success"