# r88_vcstool

[vcstool](https://github.com/dirk-thomas/vcstool) helps to track a multirepo workspace. Frequently used commands:

* `vcs branch` : Check what branch everthing is on.
* `vcs import < my.repos` : Pull all repos to the branches listed.
* `vcs status` : Show *git status* for all repos.
* `vcs pull` : Do *git pull* for all repos.

## Clone repository into `src`
```
mkdir -p ~/src/
cd ~/src/
git clone git@github.com:robotics-88/distal.git
```

## Install dependencies and set up workspace
Run the `setup_workspace.sh` script.

## Workspace setup for simulation
```
cd ~/src/distal/src/
vcs import < simulation.repos
cd ..
catkin build
```
Building may take a few tries before it succeeds. <TODO: Add link to AirSim/Unreal setup doc.>

## Workspace setup on Decco
```
cd ~/src/distal/src/
vcs import < decco.repos
cd ..
catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release
catkin build -j4
```
Building may take a few tries before it succeeds. <TODO: Add link to Mid360/Livox setup doc.> The *-j4* build arg is optional, but sometimes the Orin overloads and building is slower if you don't restrict the number of jobs.

## PRs
When creating a multi-repo PR, create a vcs file for those testing to quickly set their workspace so all repos are on the correct branch. Because github doesn't like .repos, and vcs doesn't care about the extension, name it with extension `.txt`. The file should only list those repos required for the PR. One quick way to do this is, in your workspace with all repos on the PR branches, run:

`vcs export > prname.txt`

Then delete from the file any repos not changed by the PR.