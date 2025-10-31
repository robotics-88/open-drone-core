#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../env.sh"

git lfs install

# Fetch git lfs artifacts, if not present already
cd $DRONE_DIR
git lfs fetch && git lfs pull


# Pull in repos
cd $DRONE_DIR/src/
vcs import < decco.repos
vcs pull

# Get sub-deps
cd $DRONE_DIR/src/fast-lio2
git submodule update --init --recursive

# Install general rosdeps
cd $DRONE_DIR
rosdep install --from-paths src -y --ignore-src

# Install geographiclib
wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
sudo bash ./install_geographiclib_datasets.sh  
rm install_geographiclib_datasets.sh

echo " 02 Source code fetching completed. ✅ Success"