# Assignment 4: Bash Scripts and Program PATHs
**Name:** Joseph Blenke
**Date:** February 26, 2026

## Task 1: Create programs/ directory
Created a directory called `programs/` in my home directory on the HPC to store locally installed software. Admin privileges are not available on HPC systems, so programs must be installed in a personal directory instead of system locations like `/usr/local/bin`.

## Task 2: Download and unpack gh
Used `wget` to download the gh tarball from GitHub and `tar -xzf` to extract it into `~/programs/`.

```
wget https://github.com/cli/cli/releases/download/v2.74.2/gh_2.74.2_linux_amd64.tar.gz
tar -xzf gh_2.74.2_linux_amd64.tar.gz
```

## Task 3: Build install_gh.sh
`install_gh.sh` automates the full gh installation: downloads the tarball with `wget`, extracts with `tar`, removes the tarball with `rm`, and adds the binary location to `$PATH`. Stored in `~/programs/`.

```bash
#!/bin/bash
set -ueo pipefail

wget https://github.com/cli/cli/releases/download/v2.74.2/gh_2.74.2_linux_amd64.tar.gz
tar -xzf gh_2.74.2_linux_amd64.tar.gz
rm gh_2.74.2_linux_amd64.tar.gz
export PATH=${PATH}:/sciclone/home/ajblenke/programs/gh_2.74.2_linux_amd64/bin
```

## Task 4: Add gh to $PATH
Added the gh binary location to `~/.bashrc` using `echo >>` to make it accessible from anywhere.

```
echo "export PATH=$PATH:/sciclone/home/ajblenke/programs/gh_2.74.2_linux_amd64/bin" >> ~/.bashrc
source ~/.bashrc
```

## Task 5: Run gh auth login
Set up GitHub authentication on the HPC using `gh auth login`, enabling git push/pull from the HPC.

```
gh auth login
```

## Task 6: Create install_seqtk.sh
Built `install_seqtk.sh` which clones seqtk from GitHub, compiles it with `make`, and adds it to `$PATH` via `~/.bashrc`. Stored in `~/programs/`.

```bash
#!/bin/bash
set -ueo pipefail

cd /sciclone/home/ajblenke/programs/
git clone https://github.com/lh3/seqtk.git
cd seqtk; make
echo "export PATH=$PATH:/sciclone/home/ajblenke/programs/seqtk" >> ~/.bashrc
```

## Task 7: Explore seqtk
Explored seqtk by running it with no arguments to see available subcommands. Key commands include `comp` for nucleotide composition and `subseq` for extracting sequences.

```
seqtk
```

## Task 8: Write summarize_fasta.sh
Built `summarize_fasta.sh` that accepts a fasta file as `$1` and reports total sequences, total nucleotides, and a table of sequence names and lengths using `seqtk comp`. Stored in `~/programs/`.

```bash
#!/bin/bash
set -ueo pipefail

fasta=$1

echo "Total number of sequences:"
seqtk comp $fasta | wc -l

echo "Total number of nucleotides:"
seqtk comp $fasta | awk '{sum += $2} END {print sum}'

echo "Sequence names and lengths:"
seqtk comp $fasta | cut -f 1,2
```

`fasta=$1` stores the filename passed to the script as a variable. `seqtk comp` outputs one line per sequence with the name, length, and nucleotide counts. Piping to `wc -l` counts sequences, `awk` sums the length column for total nucleotides, and `cut -f 1,2` extracts only the name and length columns.

## Task 9: Run summarize_fasta.sh in a loop
Used a for-loop with `*.fasta` wildcard to run `summarize_fasta.sh` on multiple fasta files stored in `assignment_4/data/`.

```bash
#!/bin/bash
set -ueo pipefail

for file in *.fasta; do
    echo "Processing: $file"
    summarize_fasta.sh $file
done

echo "Done"
```

```
for file in *.fasta; do summarize_fasta.sh $file; done
```

## Reflection

One of the biggest challenges I ran into during this assignment was accidentally erasing my `~/.bashrc` file. While trying to add my `gh` binary location to `$PATH`, I don't really know what happend since I used`>>` but I still managed to overwrite the entire file instead of appending to it. This broke my shell environment and I had to figure out how to restore it. I found that `/etc/bashrc` contained the system-wide default configuration for the HPC and was able to copy it back with `cp /etc/bashrc ~/.bashrc` and then re-add my PATH exports. It was a stressful moment but taught me the importance of properly using `>>` when appending to important files and the warning in Task 6 about never using `>` with `~/.bashrc` made a lot more sense after going through that experience firsthand.

Another thing I struggled with was understanding the `awk` command used in `summarize_fasta.sh`. The line `awk '{sum += $2} END {print sum}'` was not intuitive to me at first. I used Claude to help me work through it `$2` refers to the second column of the output (the sequence length), `sum += $2` adds each length to a running total as `awk` processes each line, and `END {print sum}` prints the final total only after all lines have been processed. Once it was broken down like that it made sense, but it was a good example of how a single line of code can do a lot of work that would take much longer to write in a traditional programming language.

A workflow tip that made this assignment significantly easier was keeping two terminal tabs open at the same time, one in `~/programs/` for writing and editing scripts, and one in `assignment_04/data/` for testing them. This way I could quickly switch between making changes to a script and running it on my fasta files without having to navigate back and forth every time.

`$PATH` is an environment variable that tells the shell where to look for programs when you type a command. By adding the location of a script or binary to `$PATH`, you can run it from anywhere without typing the full file path every time. Putting the `export PATH` line in `~/.bashrc` makes it system-wide and persistent, meaning it will be set automatically every time you open a new terminal session.
