#!/bin/bash
dir=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s06.XIC/02.bam
sp=$1

cat $sp|while read sample
do
    indir=$dir/$sample/chromosomes

	echo "cat $indir/*g.vcf |grep -v '#'> $dir/$sample/$sample.All.g.vcf" > $sample.mergeSNP.tmp.sh

		qsub -cwd -l vf=2g,io=0,p=1 -V $sample.mergeSNP.tmp.sh
done
