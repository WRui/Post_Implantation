#!/bin/bash
sample=$1
script=/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/StatInfo/00.Info/bin/CpG_Coverage_MethRatio.pl
indir=/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/02.SingleC
outdir=/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/StatInfo/00.Info
script_nonCG=/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/StatInfo/00.Info/bin/nonCG_Coverage_MethRatio.pl
cat $sample|while read sp
do
	echo "/WPSnew/wangrui/bin/perl $script $indir/$sp/$sp.SingleC.txt $outdir/$sp.coverage.txt $sp" > $sp.coverage.tmp.sh
	qsub -cwd -l vf=3g,io=0,p=2 -V $sp.coverage.tmp.sh
	echo "/WPSnew/wangrui/bin/perl $script_nonCG $indir/$sp/$sp.SingleC.txt $outdir/$sp.nonCG.coverage.txt $sp " > $sp.nonCG.coverage.tmp.sh
	qsub -cwd -l vf=3g,io=0,p=2 -V $sp.nonCG.coverage.tmp.sh
done
