#!/bin/bash

# Create vars
DRONE_DIR="$HOME/src/open-drone-core"
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
sudo apt install ros-humble-ros-base ros-dev-tools

source /opt/ros/humble/setup.bash

sudo apt install -y python3-rosdep python3-vcstool python3-colcon-common-extensions
sudo rosdep init
rosdep update


# Install clang compiler and other optimizations
sudo apt install -y clang lld libomp-dev ccache git-lfs python3-colcon-mixin libstdc++-12-dev
colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml
colcon mixin update default
git lfs install

# Fetch git lfs artifacts, if not present already
cd $DRONE_DIR
git lfs fetch && git lfs pull


# Pull in repos
cd $DRONE_DIR/src/
vcs import < decco.repos
vcs pull

# Get sub-deps
cd $DRONE_DIR/src/fast-lio2
git submodule update --init --recursive

# Clone rest API
cd $HOME/src/
git clone https://github.com/robotics-88/open-drone-server.git
cd open-drone-server
python3 -m venv .env
source .env/bin/activate
pip install -r requirements.txt
deactivate

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
cd $DRONE_DIR
rosdep install --from-paths src -y --ignore-src

# Install geographiclib
wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
sudo bash ./install_geographiclib_datasets.sh  
rm install_geographiclib_datasets.sh

# Hardware config
cd $DRONE_DIR
sudo apt install -y $DRONE_DIR/assets/seekthermal-sdk-dev-4.4.2.20_arm64.deb
sudo cp $DRONE_DIR/src/vehicle-launch/config/99-decco.rules /etc/udev/rules.d/
sudo cp $DRONE_DIR/src/vehicle-launch/config/decco.service /etc/systemd/system/
sudo systemctl enable decco.service
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo usermod -a -G dialout $USER
sudo nmcli con mod "Wired connection 1" ipv4.addresses "192.168.1.5/24" ipv4.gateway "192.168.1.1" ipv4.method "manual"

echo "source /opt/ros/humble/setup.bash" >> $HOME/.bashrc
echo "source $LIVOX_DIR/install/setup.bash" >> $HOME/.bashrc
echo "source $DRONE_DIR/install/setup.bash" >> $HOME/.bashrc

######################################################## Support services

# where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Install MediaMTX for video streaming
cd $HOME/src/
mkdir video
cd video
bash "$SCRIPT_DIR/install_mediamtx.sh" -s

# Install file manager
cd $HOME/src/
bash "$SCRIPT_DIR/install_filemanager.sh" -s

# mDNS for name instead of IP
sudo apt install avahi-daemon avahi-utils
sudo hostnamectl set-hostname drone
# start on boot
sudo systemctl enable avahi-daemon
sudo systemctl start avahi-daemon