#!/bin/bash
dir=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s06.XIC
indir=$dir/00.raw_data
outdir=$dir/00.split_fastq
mkdir -p $outdir
for sp in Volunter15 #Volunter13 Volunter14
do
	#mkdir -p $outdir/$sp
	rm -f $outdir/${sp}_R[12]_split_*
	echo "/WPSnew/wangrui/bin/split -l 100000000 <(gunzip -c $indir/$sp/${sp}_R1.fastq.gz) $outdir/${sp}_R1_split_ " > $sp.R1.tmp.sh
	echo "/WPSnew/wangrui/bin/split -l 100000000 <(gunzip -c $indir/$sp/${sp}_R2.fastq.gz) $outdir/${sp}_R2_split_ " > $sp.R2.tmp.sh
	qsub -cwd -l vf=3g,io=0,p=1 -V $sp.R1.tmp.sh
	qsub -cwd -l vf=3g,io=0,p=1 -V $sp.R2.tmp.sh
done
