# Assignment 2: HPC Access & Remote File Transfer
**Name:** Joseph Blenke
**Date:** February 11, 2026

## Directory Structure

```
~/SUPERCOMPUTING/assignments/assignment_02/
└── data/
    ├── GCF_000005845.2_ASM584v2_genomic.fna.gz
    └── GCF_000005845.2_ASM584v2_genomic.gff.gz
```

## Task 1: Set Up Your Semester Workspace on the HPC

Made a new directory called data in my SUPERCOMPUTING folder on the HPC.

**(HPC)**
```bash
mkdir -p assignments/assignment_02/data
```

## Task 2: Download Files from NCBI via Command-Line FTP

Logged in using ftp:

**(Local)**
```bash
ftp ftp.ncbi.nlm.nih.gov
cd  genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/
mget GCF_000005845.2_ASM584v2_genomic.fna.gz GCF_000005845.2_ASM584v2_genomic.gff.gz
bye
```

## Task 3: File Transfer and Permissions

Checked the permission on the files on local computer:

**(Local)**
```bash
ll -ash
```

Both have `-rw-rw-r--`

Organized as file type, owner, group, and other which comes in sets of 3.
The first `-` is to indicate the file type, in this case it means it has no special type. `rw-` states that I have read and write permission but not permission to execute and this is also the same for other people in my group. Then anyone else or "other" just has read permission.

Then logged into filezilla as well as the hpc, navigated to `SUPERCOMPUTING/assignments/assignment_02/data`, and moved the files. However, when I transferred the files from my local computer to the HPC the file permissions changed to `-rw-------` and I had to use chmod. I found a chmod cheatsheet on reddit and was easily able to solve this problem using the command `chmod 664 filename`. 

![chmod cheatsheet](https://i.redd.it/vkxuqbatopk21.png)

## Task 4: Verify File Integrity with md5sum

md5sum in my local system:

```
c13d459b5caa702ff7e1f26fe44b8ad7  GCF_000005845.2_ASM584v2_genomic.fna.gz
2238238dd39e11329547d26ab138be41  GCF_000005845.2_ASM584v2_genomic.gff.gz
```

md5sum on the HPC:

```
c13d459b5caa702ff7e1f26fe44b8ad7  GCF_000005845.2_ASM584v2_genomic.fna.gz
2238238dd39e11329547d26ab138be41  GCF_000005845.2_ASM584v2_genomic.gff.gz
```

Since they are the same the data wasn't corrupted.

## Task 5: Create Useful Bash Aliases

**(HPC)**
```bash
nano ~/.bashrc
```

```bash
alias u='cd ..;clear;pwd;ls -alFh --group-directories-first'
alias d='cd -;clear;pwd;ls -alFh --group-directories-first'
alias ll='ls -alFh --group-directories-first'
```

```
Ctrl + O
Ctrl + X
```

```
source ~/.bashrc
```

`u` works as an "up" function. `cd ..` moves one directory up, `clear` clears the terminal, `pwd` prints the working directory, and `ls -alFh --group-directories-first` lists all files in long format with human-readable sizes and directories grouped first.

`d` works as a "down" or "back" function. `cd -` returns to the previous directory, then runs the same `clear`, `pwd`, and `ls` commands as `u`.

`ll` is a "long list" shortcut. `ls -alFh --group-directories-first` lists all files including hidden ones, in long format with human-readable sizes, file-type indicators (`/`, `*`, `@`), and directories grouped before files.

[ls -F symbols explained](https://unix.stackexchange.com/questions/82357/what-do-the-symbols-displayed-by-ls-f-mean)
[ls command guide](https://linuxize.com/post/how-to-list-files-in-linux-using-the-ls-command/)


## Reflection

When working on this assignment I found myself constantly going down rabbit holes and I was able to have a lot of fun with it. I was looking into the different ways I could use the alias shortcut to link it to websites as well as how I could more productively use markdown text for a better visual experience. I recognized `chmod` as when downloading applications I would have trouble with the permissions and would need to fix it. I also decided that the
clear function wasn't working in my work flow since I enjoy being able to go back and look at my code, so I decided to remove it.
