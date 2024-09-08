#!/bin/bash

source /opt/ros/humble/setup.bash

cd ../

# Install Livox SDK
git clone https://github.com/Livox-SDK/Livox-SDK2.git && \
    cd Livox-SDK2 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j3 && \
    sudo make install && \
    cd ../..

# Install Livox ROS driver
mkdir -p livox_ros_driver2/src && \
    cd livox_ros_driver2/src && \
    git clone https://github.com/Livox-SDK/livox_ros_driver2.git && \
    cd ../ && \
    rosdep install --from-paths src -y --ignore-src && \
    cd src/livox_ros_driver2 && \
    ./build.sh humble && \
    cd ../../..

source livox_ros_driver2/install/setup.bash

# Install general rosdeps
cd distal/
rosdep install --from-paths src -y --ignore-src

# Install geographiclib
sudo ./src/mavros/mavros/scripts/install_geographiclib_datasets.sh

# Install seek sdk
sudo cp assets/Seek_Thermal_SDK_4.4.2.20.zip .. && \
    cd .. && \
    sudo unzip Seek_Thermal_SDK_4.4.2.20.zip && \
    sudo cp Seek_Thermal_SDK_4.4.2.20/x86_64-linux-gnu/lib/libseekcamera.so /usr/local/lib && \
    sudo cp Seek_Thermal_SDK_4.4.2.20/x86_64-linux-gnu/lib/libseekcamera.so.4.4 /usr/local/lib && \
    sudo cp -r Seek_Thermal_SDK_4.4.2.20/x86_64-linux-gnu/include/* /usr/local/include && \
    sudo cp Seek_Thermal_SDK_4.4.2.20/x86_64-linux-gnu/driver/udev/10-seekthermal.rules /etc/udev/rules.d && \
    sudo chmod u+x Seek_Thermal_SDK_4.4.2.20/x86_64-linux-gnu/bin/*

sudo usermod -a -G dialout $USER
