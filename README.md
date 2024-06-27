# distal

Codebase for Robotics 88 drone/sim ROS packages.

### Clone repository into `src`
```
mkdir -p ~/src/
cd ~/src/
git clone git@github.com:robotics-88/distal.git
cd distal
```

### Install dependencies and set up workspace
Run 
```
./setup_workspace.sh
```

### Build
```
catkin build
```
Building may take a few tries before it succeeds. On Decco, you may want to add `-j4` as an argument after `catkin build`, because sometimes the Orin overloads and building is slower if you don't restrict the number of jobs.

### Running the code
Sim:
```
roslaunch vehicle_launch decco.launch simulate:=true slam_type:=0
```
Decco:
```
roslaunch vehicle_launch decco.launch
```
You can of course add whatever arguments are available in decco launch in addition. If you get RLException, try again in a new bash terminal window (so that the .bashrc sources the environment setup variables for this ROS workspace).

### PRs
When creating a multi-repo PR, create a vcs file for those testing to quickly set their workspace so all repos are on the correct branch. Because github doesn't like .repos, and vcs doesn't care about the extension, name it with extension `.txt`. The file should only list those repos required for the PR. One quick way to do this is, in your workspace with all repos on the PR branches, run:

`vcs export > prname.txt`

Then delete from the file any repos not changed by the PR.

### vcstool tips

[vcstool](https://github.com/dirk-thomas/vcstool) helps to track a multirepo workspace. Frequently used commands:

* `vcs branch` : Check what branch everthing is on.
* `vcs import < my.repos` : Pull all repos to the branches listed.
* `vcs status` : Show *git status* for all repos.
* `vcs pull` : Do *git pull* for all repos.
