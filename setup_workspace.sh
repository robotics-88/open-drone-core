#!/bin/bash

echo "Is this a simulation environment or Decco?"
echo "Enter 's' for simulation or 'd' for Decco."
read input

if [ "$input" != "s" ] && [ "$input" != "d" ]; then
    echo "Invalid input. Please enter 's' or 'd'."
    exit 1
fi

if [ "$input" == "s" ]; then
    vcs import < simulation.repos
elif [ "$input" == "d" ]; then
    vcs import < decco.repos
fi
