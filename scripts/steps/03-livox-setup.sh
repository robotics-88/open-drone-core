#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

# Install Livox SDK
cd $HOME/src/
git clone https://github.com/Livox-SDK/Livox-SDK2.git
cd Livox-SDK2 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j3 && \
    sudo make install

# Install Livox ROS driver
mkdir -p $LIVOX_DIR/src
cd $LIVOX_DIR/src
git clone https://github.com/Livox-SDK/livox_ros_driver2.git
cd $LIVOX_DIR
rosdep install --from-paths src -y --ignore-src
cd src/livox_ros_driver2
./build.sh humble
source $LIVOX_DIR/install/setup.bash