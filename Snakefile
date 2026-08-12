rule all:
	input:
		"results/fastqc/sample1_R1__fastqc.html",
		"results/fastqc/sample1_R2__fastqc.html",
		"results/alignment/sample1.sam",
		"results/bam/sample1.sorted.bam"	
								
rule fastqc:
	input:
		r1="data/raw/sample1_R1_.fastq.gz",
		r2="data/raw/sample1_R2_.fastq.gz"
	
	output:
		html1="results/fastqc/sample1_R1__fastqc.html",
		html2="results/fastqc/sample1_R2__fastqc.html"

	shell:
		"""
		fastqc {input.r1} {input.r2} --outdir results/fastqc
		"""

rule align:
	input:
		r1="data/raw/sample1_R1_.fastq.gz",
		r2="data/raw/sample1_R2_.fastq.gz",
		index="reference/hisat2_index/ecoli.1.ht2"

	output:
		"results/alignment/sample1.sam"
	
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
		"results/alignment/sample1.sam"
		
	output:
		"results/bam/sample1.sorted.bam"

	shell:
		"""
		samtools sort \
		-o {output} \
		{input}
		"""



