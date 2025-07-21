#!/bin/bash

set -e

echo "[1/6] Installing dependencies..."
sudo apt update
sudo apt install -y ffmpeg v4l-utils v4l2loopback-dkms v4l2loopback-utils

echo "[2/6] Downloading and installing MediaMTX..."
cd $HOME/src/
mkdir video
cd video
wget -nc https://github.com/bluenviron/mediamtx/releases/download/v1.8.1/mediamtx_v1.8.1_linux_arm64v8.tar.gz
tar -xf mediamtx_v1.8.1_linux_arm64v8.tar.gz

echo "[3/6] Writing mediamtx.yml config..."
cat <<EOF > mediamtx.yml
paths:
  mapir:
    runOnDemand: ffmpeg -f v4l2 -i /dev/video21 -pix_fmt yuv420p -c:v libx264 -preset ultrafast -tune zerolatency -b:v 1M -f rtsp rtsp://localhost:\$RTSP_PORT/\$MTX_PATH
    runOnDemandRestart: yes
  thermal:
    runOnDemand: ffmpeg -f v4l2 -i /dev/video22 -pix_fmt yuv420p -c:v libx264 -preset ultrafast -tune zerolatency -b:v 600k -f rtsp rtsp://localhost:\$RTSP_PORT/\$MTX_PATH
    runOnDemandRestart: yes
EOF

echo "[4/6] Installing mediamtx to system..."
sudo cp mediamtx /usr/local/bin/
sudo cp mediamtx.yml /usr/local/etc/

echo "[5/6] Creating systemd service..."
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

echo "✔ MediaMTX setup complete and running as a systemd service."
