#!/bin/bash

source /opt/ros/humble/setup.bash
source /home/$USER/src/livox_ws/install/setup.bash
source /home/$USER/src/distal/install/setup.bash
export AIRSIM_DIR="/home/$USER/src/Colosseum"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

ros2 launch vehicle_launch decco.launch simulate:=true $@