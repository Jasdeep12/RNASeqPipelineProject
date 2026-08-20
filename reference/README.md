# Reference Genome

## Organism

Escherichia coli K-12 MG1655

## Genome Assembly

NCBI RefSeq:
GCF_000005845.2
ASM584v2

## Genome File

`genome.fna`

Source:

NCBI RefSeq

## Annotation

`genomic.gff`

Source:

NCBI RefSeq

## HISAT2 Index

The HISAT2 index was built from:

`genome.fna`

Index prefix:

`reference/hisat2_index/ecoli`

## Recreate the HISAT2 Index

```bash
hisat2-build \
    reference/genome.fa \
    reference/hisat2_index/ecoli

## Checksums

```text
PASTE_GENOME_SHA256_HERE  genome.fa
PASTE_GFF_SHA256_HERE     genes.gff
