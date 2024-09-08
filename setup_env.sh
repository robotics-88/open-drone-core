#!/bin/bash

source /opt/ros/humble/setup.bash

cd ../

# Install Livox SDK
git clone https://github.com/Livox-SDK/Livox-SDK2.git && \
    cd Livox-SDK2 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j && \
    sudo make install && \
    cd ../..

# Install Livox ROS driver
git clone https://github.com/Livox-SDK/livox_ros_driver2.git && \
    rosdep install --from-paths livox_ros_driver2 -y --ignore-src && \
    cd livox_ros_driver2 && \
    ./build.sh humble"

