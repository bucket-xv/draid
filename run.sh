#!/bin/bash

# This script is used to run the grid-simple.py script with the given arguments.
# Example: ./run.sh setup
#          ./run.sh run

cd docker
python grid-simple.py -c single2 -e eth0 -d 2 -p 1 -m $@