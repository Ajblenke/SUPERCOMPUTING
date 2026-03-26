#!/bin/bash
#SBATCH --job-name=assignment_7
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --time=2-00:00:00
#SBATCH --mem=64G
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --mail-user=ajblenke@wm.edu
#SBATCH -o /sciclone/home/ajblenke/SUPERCOMPUTING/assignments/assignment_07/output/assignment_7.out
#SBATCH -e /sciclone/home/ajblenke/SUPERCOMPUTING/assignments/assignment_07/output/assignment_7.err

# add programs to PATH
export PATH=$PATH:${HOME}/programs
export PATH=$PATH:${HOME}/programs/sratoolkit.3.4.1-ubuntu64/bin

# activate conda and bbmap environment
module load miniforge3
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate bbmap-env

# set scripts directory
SCRIPTS_DIR="${HOME}/SUPERCOMPUTING/assignments/assignment_07/scripts"

# run scripts in order
echo "Starting download..."
bash ${SCRIPTS_DIR}/01_download_data.sh

echo "Starting quality trimming..."
bash ${SCRIPTS_DIR}/02_clean_reads.sh

echo "Starting mapping..."
bash ${SCRIPTS_DIR}/03_map_reads.sh

echo "Pipeline complete!"
