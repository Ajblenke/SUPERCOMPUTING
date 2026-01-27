# Assignment 1 Essay

## Motivation for Learning High-Performance Computing

My name is Joseph Blenke, and I am currently a Junior majoring in Data Science with a
concentration in Spatial Data Analytics. As I progress through my studies and begin working
on larger projects, I know I will encounter computational challenges that a single machine
cannot handle. Spatial datasets are notoriously large, often containing millions of
geographic points, raster images, and complex polygon geometries. Training machine learning
models on this data and processing it efficiently will require computational resources
beyond what my laptop can provide.

What sparked my curiosity about high-performance computing is the question of scale.
Google maps is probably one the most used applications on my phone since I live overseas
and use it to keep track of all the restaurants that I've been to as well as find new restaurants.
Which makes me wonder how do companies like Google Maps process satellite imagery for the entire planet?
The answer to this question involves parallel processing and distributed computing.
I want to understand these systems not just as a user, but at a fundamental level.

## Goals for This Course

My primary goal is to develop a solid understanding of parallel processing concepts and learn how to design 
solutions that can scale across multiple processors. I want to shift my thinking from sequential, single-threaded programs
to approaches that take advantage of modern multi-core and distributed systems. While I have built multiple desktop
computers I never looked into how to use the hardware in this context.
 
I also hope to gain practical experience working with HPC systems, including submitting jobs to clusters, managing
computational resources, and troubleshooting the unique challenges that arise in distributed environments.
For my concentration in spatial analytics, these skills will be directly applicable when working with large geospatial datasets,
running spatial simulations, or training models on high-resolution imagery.

## Plan of Attack

I have already taken the first step by installing Linux on my personal machines.
I recently set up both Ubuntu and CachyOS, and I am committed to using the terminal for
my everyday operations rather than relying on graphical interfaces. This daily practice
will build the command-line understanding that is essential for working with HPC systems,
 where nearly everything is done through the shell.

Throughout the semester, I plan to approach each assignment as an opportunity to do more research about the techniques that are being 
used to understand the underlying concepts rather than just completing requirements. I have been documenting my learning process, taking notes on
new commands and techniques, and experimenting beyond what is strictly required. When I encounter concepts I do not understand, I will seek
out additional resources such as official documentation, reddit, or other forums.

## Folder Structure and Reproducible Research

The folder structure I created for this assignment is designed to support reproducible research.
The `data/` directory is split into `raw/` and `clean/` subdirectories,which enforces a critical principle: original data should never be modified.
By keeping raw data separate from processed data, I can always trace my analysis back to its source and rerun the entire pipeline if needed.

The `scripts/` folder centralizes all code, making it easy to version control and review.
The `results/` directory provides a clear destination for output files, keeping them separate from both input data and source code.
This prevents the common problem of mixing generated files with original files and makes it obvious what was produced by the analysis.

The `docs/`, `config/`, and `logs/` directories complete the structure by providing dedicated spaces for documentation, configuration parameters, and execution records.
This organization means that anyone, including my future self, can look at the project and understand the workflow from start to finish.
They can see what data went in, what code was run, what parameters were used, and what results came out.

## Why Documented Code Matters

In computational research, code is methodology. Just as a laboratory scientist must document their experimental procedures in enough detail for others to replicate the work,
computational researchers must document their code. Without documentation, even correct results become unverifiable and therefore untrustworthy from a scientific standpoint.

Documentation serves multiple purposes. It helps collaborators understand what the code does and why certain decisions were made.
It helps reviewers verify that the methodology is sound. Most importantly, it helps the original author,
who will inevitably forget the details of their own code given enough time. Writing clear comments and maintaining README files is
not extra work but an essential part of the research process. Documented code transforms a one-time analysis into a foundation that others can verify, critique, and build upon.

## About Me

Beyond this course, I am focused on building stronger technical foundations for my work in spatial data science.
My recent switch to Linux represents how I want to begin experimenting with more open-source software and developing the skills to be proficient in them at a higher level.
I have intermediate experience with programming in Python and R, but I still believe that I need to do a lot more practice to reach the goals that I have set out for myself.
I am excited to develop those capabilities this semester and eventually apply them to spatial computing problems as well as other projects of interest,
whether that involves processing large satellite datasets, running geospatial simulations, or training models on geographic data at continental or global scales.
