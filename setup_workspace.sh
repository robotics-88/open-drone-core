#!/bin/bash

if [ -z "$1" ]
  then
    echo "Is this a simulation environment or Decco?"
    echo "include '-s' for simulation or '-d' for Decco."
    exit 1
fi

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

# Pull in repos
cd ~/src/distal/src/
if [ "$1" == "-s" ]; then
    vcs import < simulation.repos
elif [ "$1" == "-d" ]; then
    vcs import < decco.repos
fi

# Install Livox SDK
cd ~/src/
git clone https://github.com/Livox-SDK/Livox-SDK2.git
cd Livox-SDK2 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j3 && \
    sudo make install

# Install Livox ROS driver
mkdir -p ~/src/livox_ros_driver2/src
cd ~/src/livox_ros_driver2/src
git clone https://github.com/Livox-SDK/livox_ros_driver2.git
cd ~/src/livox_ros_driver2
rosdep install --from-paths src -y --ignore-src
cd src/livox_ros_driver2
./build.sh humble
cd ~/src/

source livox_ros_driver2/install/setup.bash

# Install general rosdeps
cd ~/src/distal/
rosdep install --from-paths src -y --ignore-src

# Install geographiclib
cd ~/src/distal/src/mavros/mavros/scripts
sudo ./install_geographiclib_datasets.sh

# Install seek sdk
if [ "$1" == "-s" ]; then
    SEEK_DIR="x86_64-linux-gnu"
elif [ "$1" == "-d" ]; then
    SEEK_DIR="aarch64-linux-gnu"
fi

cd ~/src/distal/
sudo cp assets/Seek_Thermal_SDK_4.4.2.20.zip .. && \
    cd .. && \
    sudo unzip Seek_Thermal_SDK_4.4.2.20.zip && \
    sudo cp Seek_Thermal_SDK_4.4.2.20/$SEEK_DIR/lib/libseekcamera.so /usr/local/lib && \
    sudo cp Seek_Thermal_SDK_4.4.2.20/$SEEK_DIR/lib/libseekcamera.so.4.4 /usr/local/lib && \
    sudo cp -r Seek_Thermal_SDK_4.4.2.20/$SEEK_DIR/include/* /usr/local/include && \
    sudo cp Seek_Thermal_SDK_4.4.2.20/$SEEK_DIR/driver/udev/10-seekthermal.rules /etc/udev/rules.d && \
    sudo chmod u+x Seek_Thermal_SDK_4.4.2.20/$SEEK_DIR/bin/* && \
    rm Seek_Thermal_SDK_4.4.2.20.zip

# Other config
sudo cp ~/src/distal/src/vehicle-launch/config/99-r88.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo usermod -a -G dialout $USER

if [ "$1" == "-d" ]; then
    sudo nmcli con mod "Wired connection 1" ipv4.addresses "192.168.1.5/24" ipv4.gateway "192.168.1.1" ipv4.method "manual"
    sudo route add 192.168.1.12 eth0
fi

echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
echo "source /home/$USER/src/livox_ros_driver2/install/setup.bash" >> ~/.bashrc
echo "source /home/$USER/src/distal/install/setup.bash" >> ~/.bashrc
echo "export AIRSIM_DIR="/home/$USER/src/Colosseum"" >> ~/.bashrc
