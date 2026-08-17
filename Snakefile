import pandas as pd

samples = pd.read_csv("config/samples.tsv", sep="\t")
SAMPLES = samples["sample"].tolist()



rule all:
	input:
		expand("results/fastqc/{sample}_R1__fastqc.html",
		sample=SAMPLES
	),
		expand("results/fastqc/{sample}_R2__fastqc.html",
		sample=SAMPLES
	),	
		expand("results/bam/{sample}.sorted.bam.bai",	
		sample=SAMPLES
	),	
		expand("results/counts/{sample}_counts.txt",
		sample=SAMPLES
	),
		expand("results/counts/{sample}_counts.txt.summary",
		sample=SAMPLES
	)		
									
rule fastqc:
	input:
		r1="data/raw/{sample}_R1_.fastq.gz",
		r2="data/raw/{sample}_R2_.fastq.gz"
	
	output:
		html1="results/fastqc/{sample}_R1__fastqc.html",
		html2="results/fastqc/{sample}_R2__fastqc.html"

	shell:
		"""
		fastqc {input.r1} {input.r2} --outdir results/fastqc
		"""

rule align:
	input:
		r1="data/raw/{sample}_R1_.fastq.gz",
		r2="data/raw/{sample}_R2_.fastq.gz",
		index="reference/hisat2_index/ecoli.1.ht2"

	output:
		"results/alignment/{sample}.sam"
	
	shell:
		"""
		hisat2 \
		-x reference/hisat2_index/ecoli \
		-1 {input.r1} \
		-2 {input.r2} \
		-S {output}
		"""

rule sam_to_bam:
	input:
		"results/alignment/{sample}.sam"
		
	output:
		"results/bam/{sample}.sorted.bam"

	shell:
		"""
		samtools sort \
		-o {output} \
		{input}
		"""

rule index_bam:
	input:
		"results/bam/{sample}.sorted.bam"

	output:
		"results/bam/{sample}.sorted.bam.bai"
	shell:
		"""
		samtools index {input} {output}
		"""
rule quanitify:
	input: 
		bam="results/bam/{sample}.sorted.bam",
		annotation="reference/genomic.gff"
	output:
		counts="results/counts/{sample}_counts.txt",
		summary="results/counts/{sample}_counts.txt.summary"

	shell:
		"""
		featureCounts -p \
			-a {input.annotation} \
			-o {output.counts} \
			-t gene \
			-g locus_tag \
			{input.bam}
		"""
