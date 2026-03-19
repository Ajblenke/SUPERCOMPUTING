#!/bin/bash
set -ueo pipefail

# download the file
wget https://zenodo.org/records/15730819/files/SRR33939694.fastq.gz

# move file to data
mv SRR33939694.fastq.gz ./data/
