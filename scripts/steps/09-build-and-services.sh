#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../env.sh"

echo "source /opt/ros/humble/setup.bash" >> $HOME/.bashrc
echo "source $LIVOX_DIR/install/setup.bash" >> $HOME/.bashrc
echo "source $DRONE_DIR/install/setup.bash" >> $HOME/.bashrc

echo "Sourcing workspace…"
source "$HOME/.bashrc"
cd $DRONE_DIR
echo "📦  Building with colcon…"
colcon build

# Create systemd service for run_drone.sh
echo "Creating systemd service for Open Drone Core as drone.service.."
cat <<EOF | sudo tee /etc/systemd/system/drone.service > /dev/null
[Unit]
Description=Run Open Drone Core
After=network.target dev-cubeorange.device
Requires=dev-cubeorange.device

[Service]
Type=simple
User=$USER
WorkingDirectory=$DRONE_DIR
ExecStart=$DRONE_DIR/run_drone.sh
Restart=on-failure
Environment=HOME=$HOME
Environment=USER=$USER

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable drone.service
sudo systemctl start drone.service