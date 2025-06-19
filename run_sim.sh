#!/bin/bash

source /opt/ros/humble/setup.bash
source /home/$USER/src/open-drone-core/install/setup.bash
source /home/$USER/src/livox_ros_driver2/install/setup.bash
export AIRSIM_DIR="/home/$USER/src/Colosseum"

# default config
config_file="gazebo.yaml"

# detect if user explicitly passed config_file:=… (so we don’t stomp it),
# and also if they asked for do_airsim:=true
config_override=false
for arg in "$@"; do
  case "$arg" in
    config_file:*)  
      config_override=true
      ;;
    do_airsim:=true)
      config_file="airsim.yaml"
      ;;
  esac
done

# Get UTC date for logging
date=$(date -u '+%Y-%m-%d_%H-%M-%S')
data_directory=/home/$USER/r88_public/sim/$date/
mkdir -p "$data_directory"

# build the ros2-launch invocation
cmd=( ros2 launch vehicle_launch opendrone.launch.py
      simulate:=true
)

# only inject our default if they didn’t override it
if ! $config_override ; then
  cmd+=( config_file:="$config_file" )
fi

cmd+=( data_directory:="$data_directory" "${@}" )

# run & tee
stdbuf -oL "${cmd[@]}" 2>&1 | tee "$data_directory/distal_stdout_$date.log"
