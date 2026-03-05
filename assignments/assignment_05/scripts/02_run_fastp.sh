#!/bin/bash
set -ueo pipefail

# Stores FWD file as a variable

FWD=$1

# derives the reverse read by swapping _R1_ and _R2_ in the filename

REV=${FWD/_R1_/_R2_}

# the trimmed reverse output name by swapping .fast.gz for .trimmed.fastq.gz

FWD_OUT=${FWD/.fastq.gz/.trimmed.fastq.gz}

REV_OUT=${REV/.fastq.gz/.trimmed.fastq.gz}

fastp \
 --in1 $FWD \
 --in2 $REV \
 --out1 ${FWD_OUT/raw/trimmed} \
 --out2 ${REV_OUT/raw/trimmed} \
 --json /dev/null \
 --html /dev/null \
 --trim_front1 8 \
 --trim_front2 8 \
 --trim_tail1 20 \
 --trim_tail2 20 \
 --n_base_limit 0 \
 --length_required 100 \
 --average_qual 20
