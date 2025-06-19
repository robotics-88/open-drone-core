#!/usr/bin/env bash
set -euo pipefail

# where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "🏗️  Running workspace setup…"
# bash "$SCRIPT_DIR/setup_workspace.sh"

echo "📦  Building with colcon…"
# colcon build --packages-skip airsim_launch

echo "🚀  Starting Gazebo sim…"
gz sim -v4 -r r88.sdf  > /dev/null 2>&1 &
GAZEBO_PID=$!
# Save the PIDs for later
echo $GAZEBO_PID > "$SCRIPT_DIR/gazebo.pid"

sleep 10

# Start REST API
if lsof -iTCP:8080 -sTCP:LISTEN >/dev/null; then
  echo "⚠️  Backend already running on port 8080 – skipping."
else
  echo "🧭  Starting drone REST API…"
  (
    cd "$SCRIPT_DIR/../open-drone-server" || exit 1
    source .env/bin/activate
    exec python main.py
  ) > /dev/null 2>&1 &
  REST_PID=$!
  echo $REST_PID > "$SCRIPT_DIR/rest.pid"
fi

# Start frontend
if lsof -iTCP:8040 -sTCP:LISTEN >/dev/null; then
  echo "⚠️  Frontend already running on port 8040 – skipping."
else
  echo "🗺️  Starting Map Frontend…"
  (
    cd "$SCRIPT_DIR/../open-drone-frontend" || exit 1
    source myenv/bin/activate
    exec python main.py
  ) > /dev/null 2>&1 &
  FRONTEND_PID=$!
  echo $FRONTEND_PID > "$SCRIPT_DIR/frontend.pid"
fi

echo "🛩️  Starting ArduPilot in new terminal…"
gnome-terminal -- bash -c "cd '$SCRIPT_DIR/../r88_ardupilot'; ./run_gazebo.sh; exec bash"

echo
echo "🎯  All systems started! Spinning up ROS nodes next."
echo
echo "➡️  Run your own config with:"
echo -e "\e[35m     ./run_drone.sh config_file:=myconfig.yaml\e[0m"
echo 
echo "➡️  Stop sim:"
echo -e "\e[32m     ./stopquick.sh\e[0m"

echo "3..."
echo 
sleep 1
echo "2..."
echo
sleep 1
echo "1..."
echo
echo "🚀  Spinning up drone nodes…"

sleep 2

bash ./run_drone.sh config_file:=gazebo.yaml