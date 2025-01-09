# distal

Codebase for Robotics 88 drone/sim ROS packages.
### Install Dependencies
```
sudo apt install clang lld libomp-dev ccache git-lfs

mkdir -p ~/.ccache
touch ~/.ccache/ccache.conf
echo "max_size = 10G" >> ~/.ccache/ccache.conf

colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml
colcon mixin update default

git lfs install
```

### Clone repository into `src`
```
mkdir -p ~/src/distal_ros2
cd ~/src/
git clone git@github.com:robotics-88/distal.git distal_ros2
cd distal
```

### Install dependencies and set up workspace
Run 
```
./setup_workspace.sh
```

### Build
```
colcon build
```

### Running the code
Sim:
```
ros2 launch vehicle_launch decco.xml simulate:=true
```
Decco:
```
ros2 launch vehicle_launch decco.xml
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
