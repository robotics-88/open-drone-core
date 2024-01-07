# r88_vcstool

[vcstool](https://github.com/dirk-thomas/vcstool) helps to track a multirepo workspace. Frequently used commands:

* `vcs branch` : Check what branch everthing is on.
* `vcs import < my.repos` : Pull all repos to the branches listed.
* `vcs status` : Show *git status* for all repos.

## Install vcstool
vcstool is available as a ROS package.

```
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt install curl # if you haven't already installed curl
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install python3-vcstool
```

## Workspace setup
Make a workspace repo:
```
mkdir -p r88_dev/src
cd r88_dev/src
cp <path-to-r88_vcstool>/workspace.repos .
vcs import < workspace.repos
cd ..
catkin build
```
Building may take a few tries before it succeeds. <TODO: Add link to AirSim/Unreal setup doc.>

## Decco setup
Make a workspace repo on the Orin:
```
mkdir -p r88_dev/src
cd r88_dev/src
cp <path-to-r88_vcstool>/decco.repos .
vcs import < decco.repos
cd ..
catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release
catkin build -j4
```
Building may take a few tries before it succeeds. <TODO: Add link to Mid360/Livox setup doc.> The *-j4* build arg is optional, but sometimes the Orin overloads and building is slower if you don't restrict the number of jobs.

## PRs
When creating a multi-repo PR, create a `.repos` file for those testing to quickly set their workspace so all repos are on the correct branch. The file should only list those repos required for the PR. One quick way to do this is, in your workspace with all repos on the PR branches, run:

`vcs export > prname.repos`

Then delete from the file any repos not changed by the PR.