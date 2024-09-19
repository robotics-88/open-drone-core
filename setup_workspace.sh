#!/bin/bash

if [ -z "$1" ]
  then
    echo "Is this a simulation environment or Decco?"
    echo "include '-s' for simulation or '-d' for Decco."
    exit 1
fi

pushd src

if [ "$1" == "-s" ]; then
    vcs import < simulation.repos
elif [ "$1" == "-d" ]; then
    vcs import < decco.repos
fi

popd

#rosdep install --from-paths src -y --ignore-src
