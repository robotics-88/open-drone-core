#!/bin/bash

# Start ros nodes
source /opt/ros/humble/setup.bash
source /home/$USER/src/distal/install/setup.bash
source /home/$USER/src/livox_ros_driver2/install/setup.bash

# Get UTC date for logging
date=$(date -u '+%Y-%m-%d_%H-%M-%S')

data_directory=/home/$USER/logs/ros_logs/$date/

mkdir -p $data_directory

# Launch code
stdbuf -oL ros2 launch vehicle_launch ecco.launch \
    data_directory:=$data_directory $@ 2>&1 | tee $data_directory/stdout.log
