# Assignment 3: Exploring DNA Sequence File with Command Line Tools
**Name:** Joseph Blenke
**Date:** February 18, 2026

## Task 1: Navigate to your assignment_3/ directory and set it up

I already had this step completed prior to this assignment.

```
cd ~/SUPERCOMPUTING/assignments
mkdir assignment_0{1..8}
```

Then I set up the structure inside assignment_03:

```
cd ~/SUPERCOMPUTING/assignments/assignment_03
mkdir -p data
touch README.md
```

## Task 2: Download a fasta sequence file using wget

Downloaded the *A. thaliana* genome assembly into the data directory and uncompressed it.

```
cd data
wget https://gzahn.github.io/data/GCF_000001735.4_TAIR10.1_genomic.fna.gz
gunzip GCF_000001735.4_TAIR10.1_genomic.fna.gz
```

`wget` downloads a file from a URL. `gunzip` decompresses the `.gz` file, replacing it with the uncompressed `.fna` FASTA file.

## Task 3: Use Unix tools to explore the file contents

### Q1: How many sequences are in the FASTA file?

```
grep -c "^>" GCF_000001735.4_TAIR10.1_genomic.fna
```

**Answer: 7**

`grep` searches for lines matching a pattern. `-c` tells it to count matches instead of printing them. `^>` is a regular expression where `^` means "start of line", so this matches every header line. 

### Q2: What is the total number of nucleotides?

```
grep -v "^>" GCF_000001735.4_TAIR10.1_genomic.fna | tr -d '\n' | wc -c
```

**Answer: 119,668,634**

This is a pipeline of three commands connected with `|` (pipe), where the output of each feeds into the next. `grep -v "^>"` inverts the match with `-v`, printing only lines that do *not* start with `>` (sequence lines only, no headers). `tr -d '\n'` uses `tr` (translate) with `-d` (delete) to remove all newline characters, joining everything into one continuous string. `wc -c` counts characters.

### Q3: How many total lines are in the file?

```
wc -l GCF_000001735.4_TAIR10.1_genomic.fna
```

**Answer: 14**

`wc -l` counts lines. 14 lines means 7 headers + 7 sequences, so the file alternates: header on odd lines, sequence on even lines.

### Q4: How many header lines contain the word "mitochondrion"?

```
grep "^>" GCF_000001735.4_TAIR10.1_genomic.fna | grep -c "mitochondrion"
```

**Answer: 1**

First `grep "^>"` extracts only header lines, then we pipe those into `grep -c "mitochondrion"` to count how many contain the word "mitochondrion". We pipe through the first grep to make sure we only search headers, not sequence data.

### Q5: How many header lines contain the word "chromosome"?

```
grep "^>" GCF_000001735.4_TAIR10.1_genomic.fna | grep -c "chromosome"
```

**Answer: 5**

Same approach as Q4, just searching for "chromosome" instead.

### Q6: How many nucleotides are in each of the first 3 chromosome sequences?

Since the file alternates header/sequence lines, I can use `grep -A 1` to grab each chromosome header plus the sequence line after it.

```
grep -A 1 "chromosome 1 " GCF_000001735.4_TAIR10.1_genomic.fna | grep -v "^>" | tr -d '\n' | wc -c
```
**Chromosome 1: 30,427,672**

```
grep -A 1 "chromosome 2" GCF_000001735.4_TAIR10.1_genomic.fna | grep -v "^>" | tr -d '\n' | wc -c
```
**Chromosome 2: 19,698,290**

```
grep -A 1 "chromosome 3" GCF_000001735.4_TAIR10.1_genomic.fna | grep -v "^>" | tr -d '\n' | wc -c
```
**Chromosome 3: 23,459,831**

`grep -A 1` finds the matching line and prints it plus 1 line **A**fter it (the sequence). `grep -v "^>"` strips out the header, leaving only the sequence. `tr -d '\n'` removes the newline, and `wc -c` counts the nucleotides. Note the trailing space in `"chromosome 1 "` to avoid matching "chromosome 10" or similar.

### Q7: How many nucleotides are in the sequence for 'chromosome 5'?

```
grep -A 1 "chromosome 5" GCF_000001735.4_TAIR10.1_genomic.fna | grep -v "^>" | tr -d '\n' | wc -c
```

**Answer: 26,975,503**

Same approach as Q6, targeting chromosome 5.

### Q8: How many sequences contain "AAAAAAAAAAAAAAAA"?

```
grep -c "AAAAAAAAAAAAAAAA" GCF_000001735.4_TAIR10.1_genomic.fna
```

**Answer: 1**

`grep -c` counts lines matching the pattern. Since each sequence is on a single line, this counts how many sequences contain that 16-character A.

### Q9: Alphabetically first header?

```
grep "^>" GCF_000001735.4_TAIR10.1_genomic.fna | sort | head -1
```

**Answer: >NC_000932.1...**

`grep "^>"` extracts all 7 headers. `sort` arranges them alphabetically. `head -1` prints only the first line from the sorted output.

### Q10: Tab-separated version (header + sequence)?

```
cat GCF_000001735.4_TAIR10.1_genomic.fna | paste - -
```

`cat` prints the file contents to stdout. `paste - -` reads from stdin two lines at a time and joins each pair with a tab character. Since the file alternates header/sequence, this pairs each header with its sequence on one tab-separated line.

## Reflection

My approach for this assignment was to combine the techniques that we learned in class as well as some outside resources. I jumped around each of the questions depending on how confident I felt about the task and if I knew I had to research it. I started with the questions I felt comfortable with like Q1 and Q3 where I just needed a single command, and saved the trickier ones like Q6 and Q10 for when I had built up more confidence. The biggest thing I learned from this assignment is how powerful piping is. Each tool on its own does something simple but when combined you can answer questions about data without ever writing an actual program. For Q2, I had to combine three commands just to count nucleotides, and each one depended on the one before it to work. The pipeline approach of building up a solution one step at a time makes it much more straightforward than traditional coding, making it easier to accomplish what you want.

I spent a lot of time looking at `grep` documentation and the different ways that I can use it to help me solve the different tasks on the assignment [Grep documentation](https://www.geeksforgeeks.org/linux-unix/grep-command-in-unixlinux/). The `-A` flag which prints the searched line and n lines after the result was particularly useful for Q6. `-c` makes it count, `-v` inverts the search so it finds lines that don't match, and `-A` grabs context after a match. The `-v` flag especially was a different way of thinking because instead of searching for what I want, I'm removing what I don't want, and what's left is my answer.

I also had particular frustration with Q10 and getting the `paste` function to properly separate the headers and sequences. I looked at a couple different ways to tackle this online such as [awk](https://www.geeksforgeeks.org/linux-unix/awk-command-unixlinux-examples/) but I wanted to stick to the techniques we have learned and found a way to make it work with [paste](https://www.geeksforgeeks.org/linux-unix/paste-command-in-linux-with-examples/).

These kinds of command-line skills are essential in computational work because the data we work with is often too large for graphical tools to handle. Being able to quickly explore, filter, and summarize files directly from the terminal saves time and teaches you to think about problems in a modular way.
