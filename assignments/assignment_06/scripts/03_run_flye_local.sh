#!/bin/bash
set -ueo pipefail

# add local flye build to PATH 
export PATH=$PATH:~/programs/Flye/bin

# run flye
flye --nano-hq ./data/SRR33939694.fastq.gz \
  --out-dir ./assemblies/assembly_local \
  --threads 6 \
  --genome-size 100k

# rename
mv ./assemblies/assembly_local/assembly.fasta ./assemblies/assembly_local/local_assembly.fasta
mv ./assemblies/assembly_local/flye.log ./assemblies/assembly_local/local_flye.log

# move out
mv ./assemblies/assembly_local/local_assembly.fasta ./assemblies/
mv ./assemblies/assembly_local/local_flye.log ./assemblies/

# nuke and rebuild
rm -r ./assemblies/assembly_local
mkdir ./assemblies/assembly_local
mv ./assemblies/local_assembly.fasta ./assemblies/assembly_local/
mv ./assemblies/local_flye.log ./assemblies/assembly_local/
