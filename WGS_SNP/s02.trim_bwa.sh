#!/bin/bash
ref=/WPSnew/wangrui/Database/GATK/genome.fa
trim_galore=/WPSnew/wangrui/Software/TrimGalore-0.5.0/trim_galore
bwa=/WPSnew/lilin/software/bwa-0.7.12/bwa
samtools=/WPSnew/wangrui/Software/samtools-0.1.18/samtools
dir=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s06.XIC
indir=$dir/00.split_fastq
outdir=$dir/01.trim_data
bamout=$dir/02.bam
sample=$1
mkdir -p $bamout
mkdir -p $outdir
cat $sample|while read sp
do
	mkdir -p $outdir/$sp
	echo "
	$trim_galore --quality 20 --phred33 --stringency 3 --gzip --length 50 --paired --output_dir $outdir/$sp $indir/$sp/${sp}_R1.fastq.gz $indir/$sp/${sp}_R2.fastq.gz
	
	$bwa mem -M -t 3 $thread $ref $outdir/$sp/${sp}_R1_val_1.fq.gz $outdir/$sp/${sp}_R2_val_2.fq.gz > $bamout/$sp.sam
	$samtools view -bS $bamout/$sp.sam >$bamout/$sp.bam
rm $bamout/$sp.sam
	" > $sp.trim_bwa.tmp.sh
	qsub -cwd -l vf=7g,io=0,p=3 -V $sp.trim_bwa.tmp.sh
done
