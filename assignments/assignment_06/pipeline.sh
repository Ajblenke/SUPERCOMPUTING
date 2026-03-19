#!/bin/bash
set -ueo pipefail

# download data (Task 2)
echo "Downloading data"
./scripts/01_download_data.sh

# build flye locally (Task 3)
echo "Building Flye locally"
./scripts/02_flye_2.9.6_manual_build.sh

# install flye via conda (Task 4)
echo "Installing Flye via conda"
./scripts/02_flye_2.9.6_conda_install.sh

# run flye three ways (Task 6)
echo "Running Flye with conda"
./scripts/03_run_flye_conda.sh

echo "Running Flye with module"
./scripts/03_run_flye_module.sh

echo "Running Flye with local build."
./scripts/03_run_flye_local.sh

# compare results (Task 7)
echo "CONDA"
tail -10 ./assemblies/assembly_conda/conda_flye.log

echo "MODULE"
tail -10 ./assemblies/assembly_module/module_flye.log

echo "LOCAL"
tail -10 ./assemblies/assembly_local/local_flye.log
