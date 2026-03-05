# Assignment 5: Write Once, Run on Everything - Bash Pipelines
**Name:** Joseph Blenke
**Date:** March 4, 2026

## How to Run
From inside `assignment_05/`:
```bash
./pipeline.sh
```
This will download the raw FASTQ data, quality-trim all samples with fastp, and place trimmed reads in `data/trimmed/`.

## Directory Structure
```
assignment_05/
├── pipeline.sh              # Orchestrates the full workflow
├── scripts/
│   ├── 01_download_data.sh  # Downloads and extracts raw FASTQ data
│   └── 02_run_fastp.sh      # Runs fastp on a single sample pair
├── data/
│   ├── raw/                 # Raw FASTQ files (not tracked by git)
│   └── trimmed/             # Trimmed FASTQ output (not tracked by git)
└── log/                     # Log files
```

---

## Task 1. Setup assignment_05/ directory

I already had assignment_05 previously made and so I just need to go in and add the rest of the directory structure.

```bash
cd SUPERCOMPUTING/assignments/assignment_05
mkdir -p scripts log data/{raw,trimmed}
touch scripts/01_download_data.sh scripts/02_run_fastp.sh pipeline.sh
```

## Task 2. Script to download and prepare fastq data

`nano scripts/01_download_data.sh`

```bash
#!/bin/bash
set -ueo pipefail

# Download the data file
wget https://gzahn.github.io/data/fastq_examples.tar

# extract the content
tar -xf fastq_examples.tar

# move file to data/raw
mv *.fastq.gz data/raw/

# clean up
rm fastq_examples.tar
```

```bash
chmod +x scripts/01_download_data.sh
```

## Task 3. Install fastp

fastp is a tool for quality control and trimming of FASTQ sequencing reads. Since admin privileges are not available on the HPC, it was installed as a pre-built binary in `~/programs/`.

`nano ~/programs/install_fastp.sh`

```bash
#!/bin/bash
set -ueo pipefail

# download fastp binary
wget http://opengene.org/fastp/fastp

# make it executable
chmod +x fastp

# add programs/ to PATH permanently
echo "export PATH=$PATH:/sciclone/home/ajblenke/programs" >> ~/.bashrc
```

Make it executable and run:
```bash
chmod +x ~/programs/install_fastp.sh
cd ~/programs/
./install_fastp.sh
source ~/.bashrc
fastp --version
```

**fastp version: 1.1.0**

## Task 4. Script to run fastp

`nano scripts/02_run_fastp.sh`

```bash
#!/bin/bash
set -ueo pipefail

# store the first argument (forward read path) as a variable
FWD=$1

# derive the reverse read by swapping _R1_ for _R2_ in the filename
REV=${FWD/_R1_/_R2_}

# derive the trimmed forward output name by swapping .fastq.gz for .trimmed.fastq.gz
FWD_OUT=${FWD/.fastq.gz/.trimmed.fastq.gz}

# derive the trimmed reverse output name the same way
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
```

Test on a single sample:
```bash
chmod +x scripts/02_run_fastp.sh
./scripts/02_run_fastp.sh ./data/raw/6083_001_S1_R1_001.subset.fastq.gz
```

## Task 5. pipeline.sh

`nano pipeline.sh`

```bash
#!/bin/bash
set -euo pipefail

# download and extract raw data
./scripts/01_download_data.sh

# run fastp on each forward read
for data in ./data/raw/*_R1_*.fastq.gz; do
    ./scripts/02_run_fastp.sh $data
done
```

## Task 6. Delete data files and re-run pipeline

Removed all data files to verify the pipeline can reproduce everything from scratch:

```bash
rm data/raw/*.fastq.gz data/trimmed/*.fastq.gz
./pipeline.sh
```

Pipeline ran successfully and recreated all trimmed files.

## Task 7. Reflection

One thing I feel I really nailed in this assignment was understanding how to structure a
script and how modular scripts can work together across the HPC. Breaking the workflow into
`01_download_data.sh`, `02_run_fastp.sh`, and `pipeline.sh` made each piece easier to write, test, wand debug independently.

A key concept I got comfortable with was bash string substitution using `${FWD/_R1_/_R2_}` in particular to derive the reverse read filename directly from the forward read. I referenced my class notes to understand this pattern and it clicked once I saw how it avoids hardcoding
filenames and makes the script work on any sample automatically.

The main challenge I ran into was a trailing space after a \ line continuation in
`02_run_fastp.sh`, which caused bash to interpret `--trim_front1` as a separate command instead of a flag. It was a subtle bug that taught me to be careful with spaces in commands.

Pros of splitting into two scripts + a pipeline:
- `02_run_fastp.sh` can be tested and reused on a single sample without running the whole
pipeline
- Each script has one job, making it easier to debug
- The pipeline can be reused on any dataset just by changing the download URL

Cons:
- More files to keep track of
- Requires careful file path consistency between scripts
