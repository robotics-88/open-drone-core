#!/bin/bash
set -euo pipefail
: "${WORKSPACE_DIR:?WORKSPACE_DIR not set}"

# Default repos file
REPOS_FILE="decco.repos"

# Parse --full argument
if [[ "${1:-}" == "--full" ]]; then
    REPOS_FILE="sim_full.repos"
fi

git lfs install

# Fetch git lfs artifacts, if not present already
cd $DRONE_DIR
git lfs fetch && git lfs pull

# Pull in repos
cd $DRONE_DIR/src/
vcs import < "$REPOS_FILE"
vcs pull

# Get sub-deps
cd $DRONE_DIR/src/fast-lio2
git submodule update --init --recursive

# Install geographiclib
wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
sudo bash ./install_geographiclib_datasets.sh  
rm install_geographiclib_datasets.sh

echo " 02 Source code fetching completed. ✅ Success"