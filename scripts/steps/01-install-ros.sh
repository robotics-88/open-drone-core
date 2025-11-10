#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../env.sh"

# Previously completed?
if [ -d /opt/ros/humble ]; then
    echo "ROS Humble is already installed. Skipping installation."
else 
    # Install ROS
    ROS_VARIANT="${1:-desktop}"  # Accepts 'desktop' or 'base', defaults to 'desktop'
    sudo apt install -y software-properties-common
    sudo add-apt-repository universe
    sudo apt update && sudo apt install -y curl
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

    sudo apt update
    if [[ "$ROS_VARIANT" == "base" ]]; then
        sudo apt install -y ros-humble-ros-base ros-dev-tools
    else
        sudo apt install -y ros-humble-desktop ros-dev-tools
    fi
fi

sudo apt install -y python3-rosdep python3-vcstool python3-colcon-common-extensions
if [ -f "/etc/ros/rosdep/sources.list.d/20-default.list" ]; then
    echo "rosdep already initialized. Skipping."
else
    sudo rosdep init
    rosdep update
fi

# Install clang compiler and other optimizations
sudo apt install -y clang lld libomp-dev ccache git-lfs python3-colcon-mixin libstdc++-12-dev
if colcon mixin list | grep -q "default"; then
    echo "colcon default mixin repository already added. Skipping."
else
    colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml
    colcon mixin update default
fi

echo "01 ROS 2 Humble installation completed. ✅ Success"