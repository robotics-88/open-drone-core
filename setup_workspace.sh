#!/bin/bash

if [[ -z "$1" ]]
  then
    echo "Is this a sim, Decco, or Ecco?"
    echo "include '-s' for simulation, '-d' for Decco, or '-e' for Ecco"
    exit 1
fi

# Create vars
DISTAL_DIR="$HOME/src/distal"
LIVOX_DIR="$HOME/src/livox_ros_driver2"

# Generic deps
sudo apt install autossh pdal libpdal-dev

# Install ROS
sudo apt install software-properties-common
sudo add-apt-repository universe
sudo apt update && sudo apt install curl -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

sudo apt update
sudo apt install ros-humble-desktop

source /opt/ros/humble/setup.bash

sudo apt install -y python3-rosdep python3-vcstool python3-colcon-common-extensions
sudo rosdep init
rosdep update


# Install clang compiler and other optimizations
sudo apt install -y clang lld libomp-dev ccache git-lfs python3-colcon-mixin
colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml
colcon mixin update default
git lfs install

# Fetch git lfs artifacts, if not present already
cd $DISTAL_DIR
git lfs fetch && git lfs pull


# Pull in repos
cd $DISTAL_DIR/src/
if [[ "$1" == "-s" ]]; then
    vcs import < sim_full.repos
elif [[ "$1" == "-d" ]]; then
    vcs import < decco.repos
elif [[ "$1" == "-e" ]]; then
    vcs import < ecco.repos
fi
vcs pull

# Get sub-deps
cd $DISTAL_DIR/src/fast-lio2
git submodule update --init --recursive

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

# Install general rosdeps
cd $DISTAL_DIR
rosdep install --from-paths src -y --ignore-src

# Install geographiclib
cd $DISTAL_DIR/src/mavros/mavros/scripts
sudo ./install_geographiclib_datasets.sh

# Platform dependent config
cd $DISTAL_DIR
if [[ "$1" == "-s" ]]; then
    sudo apt install -y $DISTAL_DIR/assets/seekthermal-sdk-dev-4.4.2.20_amd64.deb
    sudo apt install -y libexiv2-dev libimage-exiftool-perl exif exiv2

    echo "export AIRSIM_DIR="$HOME/src/Colosseum"" >> $HOME/.bashrc

    # Install Gazebo
    sudo curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
    sudo apt-get update
    sudo apt-get install gz-harmonic ros-humble-ros-gzharmonic
    sudo apt install libgz-sim8-dev rapidjson-dev
    sudo apt install libopencv-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl
    echo 'export GZ_SIM_SYSTEM_PLUGIN_PATH=$HOME/gz_ws/src/ardupilot_gazebo/build:${GZ_SIM_SYSTEM_PLUGIN_PATH}' >> ~/.bashrc
    echo 'export GZ_SIM_RESOURCE_PATH=$HOME/gz_ws/src/ardupilot_gazebo/models:$HOME/gz_ws/src/ardupilot_gazebo/worlds:${GZ_SIM_RESOURCE_PATH}' >> ~/.bashrc

    mkdir -p $HOME/gz_ws/src && cd $HOME/gz_ws/src
    git clone https://github.com/robotics-88/ardupilot_gazebo
    export GZ_VERSION=harmonic
    cd ardupilot_gazebo
    mkdir build && cd build
    cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
    make -j4
elif [[ "$1" == "-d" ]]; then
    sudo apt install -y $DISTAL_DIR/assets/seekthermal-sdk-dev-4.4.2.20_arm64.deb
    sudo cp $DISTAL_DIR/src/vehicle-launch/config/99-decco.rules /etc/udev/rules.d/
    sudo cp $DISTAL_DIR/src/vehicle-launch/config/decco.service /etc/systemd/system/
    sudo systemctl enable decco.service
    sudo udevadm control --reload-rules && sudo udevadm trigger
    sudo usermod -a -G dialout $USER
    sudo nmcli con mod "Wired connection 1" ipv4.addresses "192.168.1.5/24" ipv4.gateway "192.168.1.1" ipv4.method "manual"
elif [[ "$1" == "-e" ]]; then
    sudo apt install -y ./assets/seekthermal-sdk-dev-4.4.2.20_arm64.deb
    sudo cp $DISTAL_DIR/src/vehicle-launch/config/99-ecco.rules /etc/udev/rules.d/
    sudo cp $DISTAL_DIR/src/vehicle-launch/config/ecco.service /etc/systemd/system/
    sudo systemctl enable ecco.service
    sudo udevadm control --reload-rules && sudo udevadm trigger
    sudo usermod -a -G dialout $USER
fi

echo "source /opt/ros/humble/setup.bash" >> $HOME/.bashrc
echo "source $LIVOX_DIR/install/setup.bash" >> $HOME/.bashrc
echo "source $DISTAL_DIR/install/setup.bash" >> $HOME/.bashrc
