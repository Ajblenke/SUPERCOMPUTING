# Assignment 6: Software and Environments
**Name:** Joseph Blenke  
**Date:** March 18, 2026

## How to Run
From inside `assignment_06/`:
```bash
./pipeline.sh
```
This downloads ONT data, builds Flye three ways (local, conda, module), runs assembly with each, and compares log outputs.

## Directory Structure
```
assignment_06/
├── assemblies/
│   ├── assembly_conda/
│   │   ├── conda_assembly.fasta
│   │   └── conda_flye.log
│   ├── assembly_local/
│   │   ├── local_assembly.fasta
│   │   └── local_flye.log
│   └── assembly_module/
│       ├── module_assembly.fasta
│       └── module_flye.log
├── data/
│   └── SRR33939694.fastq.gz
├── scripts/
│   ├── 01_download_data.sh
│   ├── 02_flye_2.9.6_conda_install.sh
│   ├── 02_flye_2.9.6_manual_build.sh
│   ├── 03_run_flye_conda.sh
│   ├── 03_run_flye_local.sh
│   └── 03_run_flye_module.sh
├── flye-env.yml
├── pipeline.sh
└── README.md
```

---

## Task 1: Setup assignment_06/ directory

```bash
cd ~/SUPERCOMPUTING/assignments/assignment_06
mkdir -p assemblies/{assembly_conda,assembly_local,assembly_module} data scripts
touch README.md
```

---

## Task 2: Download raw ONT data

Created `./scripts/01_download_data.sh`:

```bash
#!/bin/bash
set -ueo pipefail

# download the file
wget -O ./data/SRR33939694.fastq.gz https://zenodo.org/records/15730819/files/SRR33939694.fastq.gz
```

```bash
chmod +x ./scripts/01_download_data.sh
./scripts/01_download_data.sh
```

---

## Task 3: Get Flye v2.9.6 (local build)

Following the Flye install instructions for local building without installation:
https://github.com/mikolmogorov/Flye/blob/flye/docs/INSTALL.md#local-building-without-installation

Created `./scripts/02_flye_2.9.6_manual_build.sh`:

```bash
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
```

```bash
chmod +x ./scripts/02_flye_2.9.6_manual_build.sh
./scripts/02_flye_2.9.6_manual_build.sh
source ~/.bashrc
flye --version
```

`make` compiles Flye's C/C++ source code into an executable binary. Had to add `rm -rf Flye` at the top so the script can be re-run without failing on an existing directory.

---

## Task 4: Get Flye v2.9.6 (conda build)

Created `./scripts/02_flye_2.9.6_conda_install.sh`:

Following the conda environment pattern from Lesson 6 (bbmap installation), but substituting Flye.

```bash
#!/bin/bash
set -ueo pipefail

# load python3 and conda
module load miniforge3

# initialize conda without messing up bashrc (Lesson 6 - avoids conda init)
source "$(conda info --base)/etc/profile.d/conda.sh"

# create the flye conda environment (using mamba for speed)
mamba create -y -n flye-env flye=2.9.6 -c bioconda

# activate it
conda activate flye-env

# test it
flye --version

# export the environment to yml (Lesson 6 - sharing conda environments)
conda env export --no-builds | grep -v "^prefix:" > ./flye-env.yml

# deactivate
conda deactivate
```

```bash
chmod +x ./scripts/02_flye_2.9.6_conda_install.sh
./scripts/02_flye_2.9.6_conda_install.sh
```

The `.yml` file documents the exact environment so anyone can recreate it with `conda env create -f flye-env.yml`.

---

## Task 5: Decipher how to use Flye

```bash
flye --help
```

Key flags determined from the help output and the assignment hints:
- `--nano-hq` — high-quality nanopore reads (assignment states latest basecalling was used)
- `--out-dir` — output directory
- `--threads` — number of CPU cores (max 6 on login node)
- `--genome-size` — expected genome size. Coliphages (lambda, T4, T7) range ~40k-170k bp, so `100k` is a reasonable estimate

---

## Task 6: Run Flye 3 ways

### 6A: Conda environment

Created `./scripts/03_run_flye_conda.sh`:

```bash
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

# deactivate
conda deactivate
```

### 6B: Module environment

Created `./scripts/03_run_flye_module.sh`:

Had to find the correct module name using `module avail 2>&1 | grep -i flye`, which returned `Flye/gcc-11.4.1/2.9.6`.

```bash
#!/bin/bash
set -ueo pipefail

# load flye from HPC modules
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
```

### 6C: Local build

Created `./scripts/03_run_flye_local.sh`:

```bash
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
```

Made all three executable:
```bash
chmod +x ./scripts/03_run_flye_conda.sh
chmod +x ./scripts/03_run_flye_module.sh
chmod +x ./scripts/03_run_flye_local.sh
```

---

## Task 7: Compare log results

```bash
echo "CONDA"
tail -10 ./assemblies/assembly_conda/conda_flye.log

echo "MODULE"
tail -10 ./assemblies/assembly_module/module_flye.log

echo "LOCAL"
tail -10 ./assemblies/assembly_local/local_flye.log
```

All three methods produced the same assembly results, which makes sense since they are all running the same version (2.9.6) of the same software on the same data.

---

## Task 8: pipeline.sh

```bash
#!/bin/bash
set -ueo pipefail

# download data
echo "Downloading data"
./scripts/01_download_data.sh

# build flye locally 
echo "Building Flye locally"
./scripts/02_flye_2.9.6_manual_build.sh

# install flye via conda 
echo "Installing Flye via conda"
./scripts/02_flye_2.9.6_conda_install.sh

# run flye three ways
echo "Running Flye with conda"
./scripts/03_run_flye_conda.sh

echo "Running Flye with module"
./scripts/03_run_flye_module.sh

echo "Running Flye with local build"
./scripts/03_run_flye_local.sh

# compare results 
echo "CONDA"
tail -10 ./assemblies/assembly_conda/conda_flye.log

echo "MODULE"
tail -10 ./assemblies/assembly_module/module_flye.log

echo "LOCAL"
tail -10 ./assemblies/assembly_local/local_flye.log
```

```bash
chmod +x ./pipeline.sh
```

---

## Task 9: Delete everything and start over

```bash
rm -rf ./assemblies/assembly_conda/*
rm -rf ./assemblies/assembly_local/*
rm -rf ./assemblies/assembly_module/*
rm -f ./data/SRR33939694.fastq.gz
```

Verified clean:
```bash
ls ./data/
ls ./assemblies/assembly_conda/
```

Then ran the full pipeline:
```bash
./pipeline.sh
```

Pipeline completed successfully and reproduced all outputs.

---

## Reflection

The biggest challenge in this assignment was learning how to manage three different software environments side by side. Each method (local build, conda, and module) has its own setup steps.

A challenge I had was finding the correct module name on the HPC. Running `module load flye` failed because the HPC admins named it `Flye/gcc-11.4.1/2.9.6`. I had to use `module avail` and `grep` to find the right name. This taught me that module names are set by administrators and do not always match what you expect.

The conda installation was the most familiar since we practiced it in Lesson 6 with bbmap. The key lesson there was using `source "$(conda info --base)/etc/profile.d/conda.sh"` instead of `conda init`, which would have rewritten my `.bashrc` and caused problems on the HPC system. Exporting the environment to a `.yml` file was also new , it creates a portable record of every package and version so someone else can recreate the same environment.

I also ran into issues when re-running the pipeline. The `git clone` command failed because the Flye directory already existed in `~/programs/`. I fixed this by adding `rm -rf Flye` before the clone so the script can always start fresh.

Of the three methods, I found conda the most convenient because it handles dependencies automatically and produces a shareable `.yml` file. The module method was the easiest to use (one `module load` command), but you are limited to whatever the sysadmins have installed. The local build gives the most control but requires more manual work and careful documentation. For my next assignment, I would probably go for conda first because it is convenient and allows for  it to be reproducible. # assignment_06
