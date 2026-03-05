#!/bin/bash
set -ueo pipefail

# Downloads the data

./scripts/01_download_data.sh

# For loop that finds all forward data in data/raw and runs 02_run_fastp.sh

for data in ./data/raw/*_R1_*.fastq.gz;do ./scripts/02_run_fastp.sh $data; done
