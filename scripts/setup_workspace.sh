#!/bin/bash

echo "Is this a simulation environment or Decco?"
echo "Enter 's' for simulation or 'd' for Decco."
read input

if [ "$input" != "s" ] && [ "$input" != "d" ]; then
    echo "Invalid input. Please enter 's' or 'd'."
    exit 1
fi

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt install curl
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install python3-vcstool

catkin init

echo "source /home/$USER/src/distal/devel/setup.bash --extend" >> /home/$USER/.bashrc
echo "source /home/$USER/src/ws_livox/devel/setup.bash --extend" >> /home/$USER/.bashrc

cd src

if [ "$input" == "s" ]; then
    vcs import < simulation.repos
elif [ "$input" == "d" ]; then
    vcs import < decco.repos
    catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release
fi

sudo ./mavros/mavros/scripts/install_geographiclib_datasets.sh

cd ..

rosdep install --from-paths src --ignore-src -r -y
