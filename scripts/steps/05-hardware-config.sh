#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../env.sh"

# Hardware config
cd $DRONE_DIR
sudo apt install -y $DRONE_DIR/assets/seekthermal-sdk-dev-4.4.2.20_arm64.deb
sudo cp $DRONE_DIR/src/vehicle-launch/config/99-decco.rules /etc/udev/rules.d/
sudo cp $DRONE_DIR/src/vehicle-launch/config/decco.service /etc/systemd/system/
sudo systemctl enable decco.service
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo usermod -a -G dialout $USER
sudo nmcli con mod "Wired connection 1" ipv4.addresses "192.168.1.5/24" ipv4.gateway "192.168.1.1" ipv4.method "manual"