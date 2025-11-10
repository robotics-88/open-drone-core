#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../env.sh"

# Install Livox SDK
cd $HOME/src/
if [ -d "Livox-SDK2" ]; then
    echo "Livox-SDK2 directory already exists. Skipping clone."
else
    git clone https://github.com/Livox-SDK/Livox-SDK2.git

    cd Livox-SDK2 && \
    git pull && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j3 && \
    sudo make install
fi

# Install Livox ROS driver
if [ -d "$LIVOX_DIR" ]; then
    echo "Livox ROS driver already cloned."
else
    mkdir -p $LIVOX_DIR/src
    cd $LIVOX_DIR/src
    git clone https://github.com/Livox-SDK/livox_ros_driver2.git
fi

# Install pcl deps
sudo apt install libpcl-dev pcl-tools

cd $LIVOX_DIR
rosdep install --from-paths src -y --ignore-src
cd src/livox_ros_driver2
./build.sh humble

if ! grep -Fxq "source $LIVOX_DIR/install/setup.bash" ~/.bashrc; then
    echo "source $LIVOX_DIR/install/setup.bash" >> ~/.bashrc
    echo "Added Livox ROS setup.bash sourcing to .bashrc"
else
    echo "Livox ROS setup.bash already sourced in .bashrc"
fi

echo "03 Livox SDK and ROS driver installation completed. ✅ Success"