#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

# Clone rest API
cd $HOME/src/
git clone https://github.com/robotics-88/open-drone-server.git
cd open-drone-server
python3 -m venv .env
source .env/bin/activate
pip install -r requirements.txt
deactivate


# Create systemd service for rest backend
echo "Creating systemd service for open-drone-server..."
cat <<EOF | sudo tee /etc/systemd/system/rest-server-drone.service > /dev/null
[Unit]
Description=Open Drone Server
After=network.target

[Service]
Type=simple
User=decco
WorkingDirectory=/home/decco/src/open-drone-server
ExecStart=/home/decco/src/open-drone-server/start.sh
Environment=HOME=/home/decco
Environment=PATH=/home/decco/src/open-drone-server/.env/bin:/usr/bin:/bin
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable rest-server-drone.service
sudo systemctl start rest-server-drone.service