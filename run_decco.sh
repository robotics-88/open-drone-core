#!/bin/bash

source /opt/ros/humble/setup.bash
source /home/$USER/src/distal/install/setup.bash
source /home/$USER/src/livox_ros_driver2/install/setup.bash

# Get UTC date for logging
date=$(date -u '+%Y-%m-%d_%H-%M-%S')
data_directory=/home/$USER/r88_public/records/$date/
mkdir -p $data_directory

stdbuf -oL ros2 launch vehicle_launch decco.launch \
    enable_autonomy:=true tilted_lidar:=true \
    data_directory:=$data_directory $@ 2>&1 | tee $data_directory/distal_stdout_$date.log
