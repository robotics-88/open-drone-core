#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../env.sh"

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