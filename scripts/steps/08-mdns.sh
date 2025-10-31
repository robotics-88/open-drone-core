#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../env.sh"

# mDNS for name instead of IP
sudo apt install avahi-daemon avahi-utils
sudo hostnamectl set-hostname drone

# start on boot
sudo systemctl enable avahi-daemon
sudo systemctl start avahi-daemon

echo "08 mDNS setup completed. ✅ Success"