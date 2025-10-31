#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

APP_DIR="$HOME/src/simple-drone-file-manager"
PUBLIC_DIR="$HOME/r88_public/records"
PORT=9999

mkdir -p $PUBLIC_DIR

echo "[1/4] Cloning the repository..."
if [ -d "$APP_DIR" ]; then
    cd "$APP_DIR"
    git pull
else
    git clone https://github.com/robotics-88/simple-drone-file-manager.git "$APP_DIR"
fi

echo "[2/4] Installing npm dependencies..."
cd $APP_DIR
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
npm install

echo "[3/4] Writing .env file..."
cat <<EOF > "$APP_DIR/.env"
PUBLIC_DIRECTORY='$PUBLIC_DIR'
PORT=$PORT
EOF

echo "[4/4] Creating systemd service for file manager..."
sudo tee /etc/systemd/system/file-manager.service > /dev/null <<EOF
[Unit]
Description=Simple Drone File Manager
After=network.target

[Service]
WorkingDirectory=$APP_DIR
ExecStart=$(which npm) start
Restart=always
Environment=NODE_ENV=production
User=$USER

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading and enabling service..."
sudo systemctl daemon-reload
sudo systemctl enable file-manager
sudo systemctl start file-manager

echo "✔ Simple Drone File Manager is now running at http://localhost:$PORT"
