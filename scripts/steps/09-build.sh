#!/bin/bash
set -euo pipefail
: "${WORKSPACE_DIR:?WORKSPACE_DIR not set}"

set +u
source /opt/ros/humble/setup.bash
source "$LIVOX_DIR/install/setup.bash"
set -u

cd "$DRONE_DIR"
rosdep update
rosdep install --from-paths src -y --ignore-src \
  --skip-keys=livox_ros_driver2
  
colcon build --packages-skip airsim_launch
