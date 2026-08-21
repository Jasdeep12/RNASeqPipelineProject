import pandas as pd


configfile: "config/config.yaml"

samples = pd.read_csv("config/samples.tsv", sep="\t")
SAMPLES = samples["sample"].tolist()

HISAT2_INDEX = config["reference"]["hisat2_index"]
ALIGN_THREADS = config["threads"]["align"]
SAMTOOLS_THREADS = config["threads"]["samtools"]


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
		expand("results/qc/{sample}.flagstat.txt",
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

	conda:
		"envs/RNASeqPipelineProject.yml"

	shell:
		"""
		fastqc {input.r1} {input.r2} --outdir results/fastqc
		"""

rule align:
	input:
		r1=lambda wildcards: samples.loc[samples["sample"] == wildcards.sample, "R1"].iloc[0],
		r2=lambda wildcards: samples.loc[samples["sample"] == wildcards.sample, "R2"].iloc[0],
		index=HISAT2_INDEX + ".1.ht2"

	output:
		bam="results/bam/{sample}.sorted.bam"

	conda:
		"envs/RNASeqPipelineProject.yml"	

	log:
		"logs/{sample}.hisat2.log"
	
	threads: ALIGN_THREADS

	shell:
		"""
		hisat2 \
		-p {threads} \
		-x {HISAT2_INDEX} \
		-1 {input.r1} \
		-2 {input.r2} \
		2> {log} \
		| samtools sort \
			-@ {SAMTOOLS_THREADS} \
			-o {output.bam} \
			-
		"""

rule index_bam:
	input:
		"results/bam/{sample}.sorted.bam"

	output:
		"results/bam/{sample}.sorted.bam.bai"
	conda:
		"envs/RNASeqPipelineProject.yml"

	shell:
		"""
		samtools index {input} {output}
		"""


rule bam_qc:
	input:
		bam="results/bam/{sample}.sorted.bam"
	
	output:
		"results/qc/{sample}.flagstat.txt"
	
	conda:
		"envs/RNASeqPipelineProject.yml"

	shell:
		"""
		samtools flagstat {input.bam} > {output}
		"""


rule quantify:
	input: 
		bam="results/bam/{sample}.sorted.bam",
		annotation=config["reference"]["annotation"]
	output:
		counts="results/counts/{sample}_counts.txt",
		summary="results/counts/{sample}_counts.txt.summary"

	conda:
		"envs/RNASeqPipelineProject.yml"
	
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
		fastqc_r1=expand("results/fastqc/{sample}_R1__fastqc.zip", sample=SAMPLES),
		fastqc_r2=expand("results/fastqc/{sample}_R2__fastqc.zip", sample=SAMPLES),
		flagstat=expand("results/qc/{sample}.flagstat.txt", sample=SAMPLES),
		hisat2=expand("logs/{sample}.hisat2.log", sample=SAMPLES)
	output:
		html="results/multiqc/multiqc_report.html"

	conda:
		"envs/RNASeqPipelineProject.yml"

	shell:
		"""
		multiqc \
			results/fastqc \
			results/qc \
			logs \
			--outdir results/multiqc \
			--force
		"""
