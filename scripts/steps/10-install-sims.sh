#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../env.sh"

sudo apt install -y $DRONE_DIR/assets/seekthermal-sdk-dev-4.4.2.20_amd64.deb
sudo apt install -y libexiv2-dev libimage-exiftool-perl exif exiv2

if ! grep -q 'export AIRSIM_DIR="$HOME/src/Colosseum"' "$HOME/.bashrc"; then
    echo 'export AIRSIM_DIR="$HOME/src/Colosseum"' >> "$HOME/.bashrc"
fi
# Make sure the target directory exists
if [ -f "$HOME/Documents/AirSim/settings.json" ]; then
    echo "Warning: $HOME/Documents/AirSim/settings.json already exists, not overwriting."
else
    mkdir -p "$HOME/Documents/AirSim"
    sudo cp $DRONE_DIR/src/vehicle-launch/config/settings.json $HOME/Documents/AirSim/settings.json
fi

# Install Gazebo
if dpkg -l | grep -qw gz-harmonic; then
    echo "gz-harmonic is already installed."
else
    echo "gz-harmonic not found, proceeding with installation."
    sudo curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
    sudo apt-get update
    sudo apt-get install gz-harmonic ros-humble-ros-gzharmonic
    sudo apt install libgz-sim8-dev rapidjson-dev
    sudo apt install libopencv-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl
    if ! grep -Fxq 'export GZ_SIM_SYSTEM_PLUGIN_PATH=$HOME/gz_ws/src/ardupilot_gazebo/build:${GZ_SIM_SYSTEM_PLUGIN_PATH}' ~/.bashrc; then
        echo 'export GZ_SIM_SYSTEM_PLUGIN_PATH=$HOME/gz_ws/src/ardupilot_gazebo/build:${GZ_SIM_SYSTEM_PLUGIN_PATH}' >> ~/.bashrc
    fi
    if ! grep -Fxq 'export GZ_SIM_RESOURCE_PATH=$HOME/gz_ws/src/ardupilot_gazebo/models:$HOME/gz_ws/src/ardupilot_gazebo/worlds:${GZ_SIM_RESOURCE_PATH}' ~/.bashrc; then
        echo 'export GZ_SIM_RESOURCE_PATH=$HOME/gz_ws/src/ardupilot_gazebo/models:$HOME/gz_ws/src/ardupilot_gazebo/worlds:${GZ_SIM_RESOURCE_PATH}' >> ~/.bashrc
    fi
fi

if [ -d "$HOME/gz_ws/src/ardupilot_gazebo" ]; then
    echo "$HOME/gz_ws/src/ardupilot_gazebo already exists, skipping clone."
else
    mkdir -p $HOME/gz_ws/src && cd $HOME/gz_ws/src
    git clone https://github.com/robotics-88/ardupilot_gazebo
fi
export GZ_VERSION=harmonic
cd $HOME/gz_ws/src/ardupilot_gazebo
if [ -d "build" ]; then
    echo "ardupilot_gazebo build directory already exists, will rebuild."
else
    mkdir build
fi
cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j4

# Install ArduPilot
if [ -d "$HOME/src/r88_ardupilot" ]; then
    echo "$HOME/src/r88_ardupilot already exists, skipping clone."
else
    cd $HOME/src
    git clone --recurse-submodules https://github.com/robotics-88/r88_ardupilot.git
fi
cd $HOME/src/r88_ardupilot
Tools/environment_install/install-prereqs-ubuntu.sh -y
export PATH=$PATH:$HOME/src/r88_ardupilot/Tools/autotest
export PATH=/usr/lib/ccache:$PATH
. ~/.profile

echo "10 Simulation tools installation completed. ✅ Success"