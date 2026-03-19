#!/bin/bash
set -ueo pipefail

# load conda 
module load miniforge3
source "$(conda info --base)/etc/profile.d/conda.sh"

# activate flye environment 
conda activate flye-env

# run flye 
flye --nano-hq ./data/SRR33939694.fastq.gz \
  --out-dir ./assemblies/assembly_conda \
  --threads 6 \
  --genome-size 100k

# rename the files we want to keep
mv ./assemblies/assembly_conda/assembly.fasta ./assemblies/assembly_conda/conda_assembly.fasta
mv ./assemblies/assembly_conda/flye.log ./assemblies/assembly_conda/conda_flye.log

# move them out temporarily
mv ./assemblies/assembly_conda/conda_assembly.fasta ./assemblies/
mv ./assemblies/assembly_conda/conda_flye.log ./assemblies/

# delete everything left in the directory
rm -r ./assemblies/assembly_conda

# recreate it and move files back
mkdir ./assemblies/assembly_conda
mv ./assemblies/conda_assembly.fasta ./assemblies/assembly_conda/
mv ./assemblies/conda_flye.log ./assemblies/assembly_conda/

# deactivate (Lesson 6)
conda deactivate
