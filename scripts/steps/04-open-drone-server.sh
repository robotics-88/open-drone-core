#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../env.sh"

# Clone rest API
cd $HOME/src/
if [ -d "open-drone-server" ]; then
    echo "Directory open-drone-server already exists. Skipping clone."
else
    git clone https://github.com/robotics-88/open-drone-server.git
fi
cd open-drone-server
git pull
python3 -m venv .env
source .env/bin/activate
pip install -r requirements.txt
deactivate


# Create systemd service for rest backend
if [ -f "/etc/systemd/system/rest-server-drone.service" ]; then
    echo "Systemd service file already exists. Skipping creation. ✅ 04 Success"
    exit 0
fi
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

echo "04 Open Drone Server setup completed. ✅ Success"