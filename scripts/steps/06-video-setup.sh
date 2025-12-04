#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../env.sh"

echo "[1/6] Installing dependencies..."
sudo apt update
# Uncommented these because you need them for the config steps below
sudo apt install -y ffmpeg v4l-utils v4l2loopback-dkms v4l2loopback-utils

echo "[1.5/6] Configuring v4l2loopback..."
# 1. Create the modprobe config file
echo 'options v4l2loopback video_nr=21,22 card_label="VirtualCam1,VirtualCam2" exclusive_caps=1' | sudo tee /etc/modprobe.d/v4l2loopback.conf > /dev/null

# 2. Add to /etc/modules so it loads on boot (idempotent check)
if ! grep -q "^v4l2loopback$" /etc/modules; then
    echo "v4l2loopback" | sudo tee -a /etc/modules > /dev/null
fi

# 3. Load the module now so we don't need a reboot immediately
# We attempt to unload first in case it was loaded with old settings
sudo modprobe -r v4l2loopback 2>/dev/null || true
sudo modprobe v4l2loopback

echo "[2/6] Downloading and installing MediaMTX..."
cd $HOME/src/
if [ -d "video" ]; then
    echo "[3/6] video directory already exists. Skipping download."
    cd video
else
    mkdir video
    cd video
    wget -nc https://github.com/bluenviron/mediamtx/releases/download/v1.8.1/mediamtx_v1.8.1_linux_arm64v8.tar.gz
    tar -xf mediamtx_v1.8.1_linux_arm64v8.tar.gz
    cp mediamtx.yml mediamtx.yml.backup
    
    echo "[3/6] Configuring mediamtx.yml..."
    # Using 'EOF' (quoted) prevents $RTSP_PORT from expanding now (keeps it literal).
    # Using >> appends to the file.
    # Indentation is 2 spaces to fit under the existing "paths:" block.
    cat <<'EOF' >> mediamtx.yml
  camera1:
    runOnDemand: ffmpeg -f v4l2 -i /dev/camera1 -pix_fmt yuv420p -c:v libx264 -preset ultrafast -tune zerolatency -b:v 1M -f rtsp rtsp://localhost:$RTSP_PORT/$MTX_PATH
    runOnDemandRestart: yes
  camera2:
    runOnDemand: ffmpeg -f v4l2 -i /dev/camera2 -pix_fmt yuv420p -c:v libx264 -preset ultrafast -tune zerolatency -b:v 600k -f rtsp rtsp://localhost:$RTSP_PORT/$MTX_PATH
    runOnDemandRestart: yes
EOF
fi

if [ -f "/usr/local/bin/mediamtx" ]; then
    echo "[4/6] MediaMTX already installed. Skipping installation."
else
    echo "[4/6] Installing mediamtx to system..."
    sudo cp mediamtx /usr/local/bin/
    sudo cp mediamtx.yml /usr/local/etc/
fi

if [ -f "/etc/systemd/system/mediamtx.service" ]; then
    echo "[5/6] Systemd service file already exists. Skipping creation."
else
    echo "[5/6] Creating systemd service file..."
    sudo tee /etc/systemd/system/mediamtx.service > /dev/null <<EOF
[Unit]
Description=MediaMTX RTSP Server
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/local/bin/mediamtx /usr/local/etc/mediamtx.yml
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

    echo "[6/6] Enabling and starting systemd service..."
    sudo systemctl daemon-reload
    sudo systemctl enable mediamtx
    sudo systemctl start mediamtx
fi

echo "06 MediaMTX setup complete and running as a systemd service. ✅ Success"