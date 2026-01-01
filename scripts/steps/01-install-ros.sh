#!/bin/bash
set -euo pipefail
: "${WORKSPACE_DIR:?WORKSPACE_DIR not set}"

# Detect Ubuntu codename
. /etc/os-release
UBUNTU_CODENAME="${UBUNTU_CODENAME:-$VERSION_CODENAME}"

# Map Ubuntu → ROS 2 distro
case "$UBUNTU_CODENAME" in
    jammy) ROS_DISTRO=humble ;;
    *)
        echo "Unsupported Ubuntu version: $UBUNTU_CODENAME"
        exit 1
        ;;
esac

if [[ -d "/opt/ros/$ROS_DISTRO" ]]; then
    echo "ROS $ROS_DISTRO already installed. Skipping."
else 
    # Install ROS
    ROS_VARIANT="${1:-desktop}"  # Accepts 'desktop' or 'base', defaults to 'desktop'
    sudo apt install -y software-properties-common
    sudo add-apt-repository universe
    sudo apt update && sudo apt install -y curl
    curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
    sudo dpkg -i /tmp/ros2-apt-source.deb

    sudo apt update
    if [[ "$ROS_VARIANT" == "base" ]]; then
        sudo apt install -y ros-$ROS_DISTRO-ros-base ros-dev-tools
    else
        sudo apt install -y ros-$ROS_DISTRO-desktop ros-dev-tools
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

echo "01 ROS 2 $ROS_DISTRO installation completed. ✅ Success"