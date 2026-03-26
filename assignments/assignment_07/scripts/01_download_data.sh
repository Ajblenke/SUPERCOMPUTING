#!/bin/bash
set -ueo pipefail

# Creates paths to use throughout the script
MAIN_DIR="${HOME}/SUPERCOMPUTING/assignments/assignment_07"
RAW_DIR="${MAIN_DIR}/data/raw"
REF_DIR="${MAIN_DIR}/data/dog_reference"
METADATA="${MAIN_DIR}/data/SraRunTable.csv"

# Download raw reads for each accession in metadata file
# cut grbs column 1 (Run), tail skips the header line
for ACCESSION in $(cut -d',' -f1 "$METADATA" | tail -n +2)
do
	fasterq-dump "$ACCESSION" --split-files --outdir "$RAW_DIR"
done

# download dog reference nome using datasets
datasets download genome taxon "Canis lupus familiaris" --reference --filename "${REF_DIR}/dog_genome.zip"

# unzip and move the fasta file into place -d is used to place it in the new directory
unzip "${REF_DIR}/dog_genome.zip" -d "${REF_DIR}"

# use ls with wildcard to locate the .fna file
FNA_PATH=$(ls ${REF_DIR}/ncbi_dataset/data/*/*.fna)
mv "$FNA_PATH" "${REF_DIR}/dog_reference_genome.fna"

# clean up zip file

rm "${REF_DIR}/dog_genome.zip"
echo "Download complete!"
