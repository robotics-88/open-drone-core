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
sudo apt install autossh

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
    vcs import < privileged_developer.repos
elif [[ "$1" == "-d" ]]; then
    vcs import < decco.repos
fi
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

# Install seek sdk
cd $DISTAL_DIR
if [ "$1" == "-s" ]; then
    sudo apt install -y ./assets/seekthermal-sdk-dev-4.4.2.20_amd64.deb
elif [[ "$1" == "-d" || "$1" == "-e" ]]; then
    sudo apt install -y ./assets/seekthermal-sdk-dev-4.4.2.20_arm64.deb
fi


# Other config
if [[ "$1" == "-d"]]; then
    sudo cp $DISTAL_DIR/src/vehicle-launch/config/99-decco.rules /etc/udev/rules.d/
    sudo udevadm control --reload-rules && sudo udevadm trigger
    sudo usermod -a -G dialout $USER
    sudo nmcli con mod "Wired connection 1" ipv4.addresses "192.168.1.5/24" ipv4.gateway "192.168.1.1" ipv4.method "manual"
elif [[ "$1" == "-e" ]]; then
    sudo cp $DISTAL_DIR/src/vehicle-launch/config/99-ecco.rules /etc/udev/rules.d/
    sudo udevadm control --reload-rules && sudo udevadm trigger
    sudo usermod -a -G dialout $USER
fi

sudo udevadm control --reload-rules && sudo udevadm trigger
sudo usermod -a -G dialout $USER

if [[ "$1" == "-d" ]]; then
    sudo nmcli con mod "Wired connection 1" ipv4.addresses "192.168.1.5/24" ipv4.gateway "192.168.1.1" ipv4.method "manual"
fi

echo "source /opt/ros/humble/setup.bash" >> $HOME/.bashrc
echo "source $LIVOX_DIR/install/setup.bash" >> $HOME/.bashrc
echo "source $DISTAL_DIR/install/setup.bash" >> $HOME/.bashrc

if [[ "$1" == "-s" ]]; then
    echo "export AIRSIM_DIR="$HOME/src/Colosseum"" >> $HOME/.bashrc
fi
