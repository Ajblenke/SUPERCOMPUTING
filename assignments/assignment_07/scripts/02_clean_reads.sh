#!/bin/bash
set -ueo pipefail

# set paths
MAIN_DIR="${HOME}/SUPERCOMPUTING/assignments/assignment_07"
RAW_DIR="${MAIN_DIR}/data/raw"
CLEAN_DIR="${MAIN_DIR}/data/clean"

# loop through all forward read files in raw/
# parameter expansion derives the reverse and output filenames
for FWD in ${RAW_DIR}/*_1.fastq
do
    # derive paired filenames from forward filename
    REV=${FWD/_1.fastq/_2.fastq}
    FWD_OUT=${CLEAN_DIR}/$(basename ${FWD/_1.fastq/_1.fastq.gz})
    REV_OUT=${CLEAN_DIR}/$(basename ${REV/_2.fastq/_2.fastq.gz})

    fastp \
        --in1 "$FWD" \
        --in2 "$REV" \
        --out1 "$FWD_OUT" \
        --out2 "$REV_OUT" \
        --json /dev/null \
        --html /dev/null \
        --trim_front1 8 \
        --trim_front2 8 \
        --trim_tail1 20 \
        --trim_tail2 20 \
        --n_base_limit 0 \
        --length_required 100 \
        --average_qual 20
done

echo "Cleaning complete!"
