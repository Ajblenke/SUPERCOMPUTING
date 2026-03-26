# Assignment 7: SLURM Job Submission & Public Data
**Name:** Joseph Blenke
**Date:** March 24, 2026

## How to Run
From inside `assignment_07/`:
```bash
sbatch assignment_7_pipeline.slurm
```
This downloads 12 shotgun metagenome samples from the SRA, quality-trims them with fastp, maps them against the dog reference genome with bbmap, and extracts any positive hits with samtools.

## Directory Structure
```
assignment_07/
├── assignment_7_pipeline.slurm   
├── data/
│   ├── raw/                      
│   ├── clean/                    
│   ├── dog_reference/            
│   └── SraRunTable.csv           
├── output/                       
├── README.md
└── scripts/
    ├── 01_download_data.sh
    ├── 02_clean_reads.sh
    └── 03_map_reads.sh
```

```bash
cd ~/SUPERCOMPUTING/assignments/assignment_07
mkdir -p data/{clean,dog_reference,raw} output scripts
touch README.md
```

---

## Task 2: Download Sequence Data

Searched NCBI SRA (https://www.ncbi.nlm.nih.gov/sra) with:
```
metagenome[All Fields] AND illumina[Platform]
```
Filtered for Library Strategy: WGS and Source: METAGENOMIC. Selected 12 wastewater metagenome samples and downloaded metadata via Run Selector. `SraRunTable.csv` was uploaded to `data/` via FileZilla.

Created `scripts/01_download_data.sh` to handle downloading all accessions and the dog reference genome.

```bash
#!/bin/bash 
set -ueo pipefail

# set paths using $HOME so script works for any user
MAIN_DIR="${HOME}/SUPERCOMPUTING/assignments/assignment_07"
RAW_DIR="${MAIN_DIR}/data/raw"
REF_DIR="${MAIN_DIR}/data/dog_reference"
METADATA="${MAIN_DIR}/data/SraRunTable.csv"

# cut grabs column 1 (Run), tail skips the header line
for ACCESSION in $(cut -d',' -f1 "$METADATA" | tail -n +2)
do 
    fasterq-dump "$ACCESSION" --split-files --outdir "$RAW_DIR"
done

# download dog reference genome using datasets
datasets download genome taxon "Canis lupus familiaris" \
    --reference \
    --filename "${REF_DIR}/dog_genome.zip"

# unzip and move the fasta file into place
unzip "${REF_DIR}/dog_genome.zip" -d "${REF_DIR}" 

# use ls with wildcard to locate the .fna regardless of nested folder name
FNA_PATH=$(ls ${REF_DIR}/ncbi_dataset/data/*/*.fna)
mv "$FNA_PATH" "${REF_DIR}/dog_reference_genome.fna"

# clean up zip file 
rm "${REF_DIR}/dog_genome.zip" 

echo "Download complete!"
```

```bash
chmod +x scripts/01_download_data.sh
```
**Note:** After submission I identified that the samples selected were 
AMPLICON library type rather than WGS shotgun metagenomes as required. 
The SRA website made it difficult to filter correctly for the right 
library type. The pipeline itself is correct and will work with any 
valid paired-end Illumina metagenomic dataset, only the sample 
selection needs to be corrected.

---

## Task 3: Quality Trim Reads

Created `scripts/02_clean_reads.sh` to run fastp on all 12 sample pairs. Uses parameter expansion to derive reverse read and output filenames from the forward read filename.

```bash
#!/bin/bash
set -ueo pipefail

MAIN_DIR="${HOME}/SUPERCOMPUTING/assignments/assignment_07"
RAW_DIR="${MAIN_DIR}/data/raw"
CLEAN_DIR="${MAIN_DIR}/data/clean"

for FWD in ${RAW_DIR}/*_1.fastq
do
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
```

```bash
chmod +x scripts/02_clean_reads.sh
```

---

## Tasks 4 & 5: Map Reads and Extract Hits

Created `scripts/03_map_reads.sh` to map each clean sample pair against the dog reference genome with bbmap, then extract only the positively mapped reads with samtools.

```bash
#!/bin/bash
set -ueo pipefail

MAIN_DIR="${HOME}/SUPERCOMPUTING/assignments/assignment_07"
CLEAN_DIR="${MAIN_DIR}/data/clean"
REF="${MAIN_DIR}/data/dog_reference/dog_reference_genome.fna"
OUTPUT_DIR="${MAIN_DIR}/output"

for FWD in ${CLEAN_DIR}/*_1.fastq.gz
do
    REV=${FWD/_1.fastq.gz/_2.fastq.gz}
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

    # -F 4 excludes unmapped reads, keeping only positive hits
    samtools view -F 4 "${OUTPUT_DIR}/${SAMPLE}.sam" \
        > "${OUTPUT_DIR}/${SAMPLE}_dog-matches.sam"

    echo "Done: $SAMPLE"
done

echo "Mapping complete!"
```

```bash
chmod +x scripts/03_map_reads.sh
```

---

## Task 6: SLURM Pipeline Script

Created `assignment_7_pipeline.slurm` to tie all three scripts together and submit the full workflow to the cluster. Note: absolute paths are required in the SLURM header `$HOME` and `~` are not expanded there.

```bash
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

SCRIPTS_DIR="${HOME}/SUPERCOMPUTING/assignments/assignment_07/scripts"

echo "Starting download..."
bash ${SCRIPTS_DIR}/01_download_data.sh

echo "Starting quality trimming..."
bash ${SCRIPTS_DIR}/02_clean_reads.sh

echo "Starting mapping..."
bash ${SCRIPTS_DIR}/03_map_reads.sh

echo "Pipeline complete!"
```

Submitted with:
```bash
sbatch assignment_7_pipeline.slurm
```

Monitored with:
```bash
sacct
squeue
```

---

## Task 7: Inspect stdout and stderr

Monitored job progress by inspecting the output files:
```bash
cat output/assignment_7.out
cat output/assignment_7.err
```
The `.out` file confirmed each script ran in order. The `.err` file showed fastp 
filtering stats for each sample and bbmap mapping progress. Initial run failed 
because `fasterq-dump` and `bbmap` were not in `$PATH` — fixed by updating the 
SLURM header.

---

## Task 8: Results

QC read counts pulled from the `.err` file:
```bash
grep "reads passed filter" output/assignment_7.err
```

Mapped read counts pulled after job completion:
```bash
grep -c "." output/*_dog-matches.sam
```

| Sample | QC Reads | Reads Mapped to Dog Genome |
|---|---|---|
| DRR538767 | 125,084 |0|
| DRR538768 | 118,262 |0|
| DRR538769 | 140,950 |0|
| DRR538770 | 135,246 |0|
| DRR538771 | 121,682 |0|
| DRR538772 | 121,150 |0|
| DRR538773 | 157,776 |0|
| DRR538774 | 172,050 |0|
| DRR538775 | 170,742 |0|
| DRR538776 | 163,838 |0|
| DRR538777 | 153,822 |0|
| DRR538778 | 150,724 |0|

---

## Reflection

One of the first challenges I ran into was setting up file paths in a way that wasn't
hardcoded to my username. I remembered that `${HOME}` is an environment variable that
always points to whoever is running the script, which solved that problem. That said,
I'm not entirely sure this makes the pipeline fully reproducible for anyone on the HPC,
since tools like `fasterq-dump` and `bbmap` still need to be installed and the
`bbmap-env` conda environment needs to exist on whatever account is running it.

`fasterq-dump` and `bbmap` weren't found when SLURM ran the job because they weren't in
`$PATH` at runtime. I fixed this by explicitly adding the sratoolkit binary location to
`$PATH` in the SLURM header and activating the `bbmap-env` conda environment before the
scripts ran. The `datasets` tool also needed to be manually downloaded and added to
`~/programs/` before it could be used.

For the bbmap command I wasn't sure which flags to use, so I looked through the manual to
understand what each parameter was actually doing rather than just copying a command blindly.
No dog DNA was detected in any of the 12 samples,This confused me at first but is likely due
to the low abundance of dog DNA relative to the enormous diversity of microbial DNA in soil metagenomes.
Any trace amounts present may have fallen below the 95% identity threshold required by bbmap to count as a positive hit.

Things I learned from this assignment:
- SLURM headers require absolute paths for `-o` and `-e`: `$HOME` and `~` are not expanded there
- `fasterq-dump --split-files` automatically saves paired reads as `_1.fastq` and `_2.fastq`, which made parameter expansion in the downstream loop straightforward
- `samtools view -F 4` is a simple one-liner for keeping only mapped reads from a SAM file
