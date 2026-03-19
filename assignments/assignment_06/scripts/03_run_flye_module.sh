#!/bin/bash
set -ueo pipefail

# load flye from HPC modules (Lesson 6 - module load)
module load Flye/gcc-11.4.1/2.9.6

# run flye
flye --nano-hq ./data/SRR33939694.fastq.gz \
  --out-dir ./assemblies/assembly_module \
  --threads 6 \
  --genome-size 100k

# rename
mv ./assemblies/assembly_module/assembly.fasta ./assemblies/assembly_module/module_assembly.fasta
mv ./assemblies/assembly_module/flye.log ./assemblies/assembly_module/module_flye.log

# move out
mv ./assemblies/assembly_module/module_assembly.fasta ./assemblies/
mv ./assemblies/assembly_module/module_flye.log ./assemblies/

# nuke and rebuild
rm -r ./assemblies/assembly_module
mkdir ./assemblies/assembly_module
mv ./assemblies/module_assembly.fasta ./assemblies/assembly_module/
mv ./assemblies/module_flye.log ./assemblies/assembly_module/
