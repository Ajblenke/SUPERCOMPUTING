#!/bin/bash
set -ueo pipefail

# load python3 and conda
module load miniforge3

# initialize conda without messing up bashrc
source "$(conda info --base)/etc/profile.d/conda.sh"

# create the flye conda environment
mamba create -y -n flye-env flye=2.9.6 -c bioconda

# activate it
conda activate flye-env

# test it
flye --version

# export the environment to yml
conda env export --no-builds | grep -v "^prefix:" > ./flye-env.yml

# deactivate
conda deactivate
