#!/bin/bash
set -ueo pipefail

# set paths
MAIN_DIR="${HOME}/SUPERCOMPUTING/assignments/assignment_07"
CLEAN_DIR="${MAIN_DIR}/data/clean"
REF="${MAIN_DIR}/data/dog_reference/dog_reference_genome.fna"
OUTPUT_DIR="${MAIN_DIR}/output"

# loop through all forward clean reads
for FWD in ${CLEAN_DIR}/*_1.fastq.gz
do
    # derive reverse filename using parameter expansion
    REV=${FWD/_1.fastq.gz/_2.fastq.gz}

    # derive sample name for output files
    SAMPLE=$(basename ${FWD/_1.fastq.gz/})

    echo "Mapping: $SAMPLE"

    # map reads to dog reference genome
    bbmap.sh \
        ref="$REF" \
        in1="$FWD" \
        in2="$REV" \
        out="${OUTPUT_DIR}/${SAMPLE}.sam" \
        minid=0.95 \
        nodisk=t \
        -Xmx16g \
        threads=4

    # extract only reads that mapped to dog genome (from Lesson 7)
    # -F 4 excludes unmapped reads, keeping only positive hits
    samtools view -F 4 "${OUTPUT_DIR}/${SAMPLE}.sam" \
        > "${OUTPUT_DIR}/${SAMPLE}_dog-matches.sam"

    echo "Done: $SAMPLE"
done

echo "Mapping complete!"
