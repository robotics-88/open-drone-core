#!/bin/bash
set -euo pipefail
: "${WORKSPACE_DIR:?WORKSPACE_DIR not set}"

# Hardware config
cd $DRONE_DIR
sudo apt-get install -y $DRONE_DIR/assets/seekthermal-sdk-dev-4.4.2.20_arm64.deb
sudo cp $DRONE_DIR/src/vehicle-launch/config/99-decco.rules /etc/udev/rules.d/
sudo cp $DRONE_DIR/src/vehicle-launch/config/decco.service /etc/systemd/system/
sudo systemctl enable decco.service
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo usermod -a -G dialout $USER
sudo nmcli con mod "Wired connection 1" ipv4.addresses "192.168.1.5/24" ipv4.gateway "192.168.1.1" ipv4.method "manual"

# Create systemd service for run_drone.sh
if [ -f "/etc/systemd/system/drone.service" ]; then
    echo "Systemd service file for drone.service already exists. Skipping creation."
else 
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
fi

echo "05 Hardware configuration completed. ✅ Success"