rule all:
	input:
		"results/fastqc/sample1_R1__fastqc.html",
		"results/fastqc/sample1_R2__fastqc.html"

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
	

