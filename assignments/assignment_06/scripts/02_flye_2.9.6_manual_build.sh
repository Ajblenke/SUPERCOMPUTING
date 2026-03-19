#!/bin/bash
set -ueo pipefail

cd ~/programs

# remove old build if it exists
rm -rf Flye

# clone and build fresh
git clone --branch 2.9.6 https://github.com/mikolmogorov/Flye.git
cd Flye
make

# add flye to PATH permanently
echo "export PATH=\$PATH:~/programs/Flye/bin" >> ~/.bashrc
