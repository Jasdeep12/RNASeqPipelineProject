# RNA-seq Analysis Pipeline

**This is an educational project meant for my own learning, therefore the outputs and design might not be of fully professional design.

A RNA-seq analysis workflow for paired-end sequence data, built using Python, Snakemake, and Conda.

## Overview

This project takes paired-end RNA-seq reads from *Escherichia coli* K-12 MG1655 through QC, genome alignment, BAM processing, and gene level quantification.

This workflow is designed such that it's reproducible and scalable to multiple samples.

## Workflow

Input : Fastq
-> Fastqc
-> HISAT2
-> SAMtools sorting
-> BAM indexing
-> SAMtools flagstat
-> featureCounts
-> MultiQC

## Tools

Snakemake | Workflow management
FastQC | Read Quality Control
HISAT2 | Read alignment
SAMtools | BAM sorting and indexing
featureCounts | Gene-level quantification
MultiQC | QC report aggregation
Ncbi-tools-cli | datasets, testing and validation

## Data

Organism:

*Escherichia coli* K-12 MG1655

Example sequencing dataset:

Accession Number: SRR13970441

Reads:
Paired-end FASTQ

## Environment

This pipeline uses a Conda environment defined in:

`envs/RNASeqPipelineProject.yml`

The environment can be recreated with:

```bash
conda env create -f envs/RNASeqPipelineProject.yml

## Project Structure

```text
RNASeqPipelineProject/
|- Snakefile
|- README.md
|- config/
|	- samples.tsv
|- data/
|	- raw/
|- envs/
|	- RNASeqPipelineProject.yml
|- reference/
|	- genome.fna
|	- genomic.gff
|	- hisat2_index/
|- results/
|	- bam/
|	- counts/
|	- fastqc/
|	- multiqc/
|-scripts/

