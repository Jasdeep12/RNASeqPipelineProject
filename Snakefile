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
	),
		"results/multiqc/multiqc_report.html"	
									
rule fastqc:
	input:
		r1=lambda wildcards: samples.loc[samples["sample"] == wildcards.sample, "R1"].iloc[0],
		r2=lambda wildcards: samples.loc[samples["sample"] == wildcards.sample, "R2"].iloc[0]
	
	output:
		html1="results/fastqc/{sample}_R1__fastqc.html",
		zip1="results/fastqc/{sample}_R1__fastqc.zip",
		html2="results/fastqc/{sample}_R2__fastqc.html",
		zip2="results/fastqc/{sample}_R2__fastqc.zip"

	shell:
		"""
		fastqc {input.r1} {input.r2} --outdir results/fastqc
		"""

rule align:
	input:
		r1=lambda wildcards: samples.loc[samples["sample"] == wildcards.sample, "R1"].iloc[0],
		r2=lambda wildcards: samples.loc[samples["sample"] == wildcards.sample, "R2"].iloc[0],
		index="reference/hisat2_index/ecoli.1.ht2"

	output:
		bam="results/bam/{sample}.sorted.bam"
	
	log:
		"logs/{sample}.hisat2.log"
	
	shell:
		"""

		hisat2 \
		-x reference/hisat2_index/ecoli \
		-1 {input.r1} \
		-2 {input.r2} \
		2> {log} \
		| samtools sort \
			-o {output.bam} \
			-
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
rule quantify:
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

rule multiqc:
	input:
		expand("results/fastqc/{sample}_R1__fastqc.zip", sample=SAMPLES),
		expand("results/fastqc/{sample}_R2__fastqc.zip", sample=SAMPLES)
	output:
		html="results/multiqc/multiqc_report.html"

	shell:
		"""
		multiqc results/fastqc \
			--outdir results/multiqc \
			--force \
		"""
