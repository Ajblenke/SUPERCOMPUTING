#!/bin/bash
set -ueo pipefail

# Download the data file

wget https://gzahn.github.io/data/fastq_examples.tar

# extract the content

tar -xf fastq_examples.tar

# move file to data/raw

mv *.fastq.gz data/raw/

#  clean up 

rm fastq_examples.tar
