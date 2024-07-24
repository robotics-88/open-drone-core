#!/bin/bash

# Path to the main workspace directory
WORKSPACE_DIR="/workspaces/distal/src/"

# Iterate over all subdirectories
for dir in $(find $WORKSPACE_DIR -type d -name .git); do
  # Get the parent directory of the .git directory
  REPO_DIR=$(dirname $dir)
  echo "Setting $REPO_DIR as safe.directory"
  git config --global --add safe.directory $REPO_DIR
done
