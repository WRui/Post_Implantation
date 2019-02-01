#!/bin/bash
sample=$1
script=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s07.FullLengthRNA/bin/s01.Run_RNA_AllProcess.sh
inpath=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s07.FullLengthRNA
cat $sample|while read sp
do
	echo "bash $script $inpath $sp" >$sp.tmp.sh
	qsub -cwd -l vf=2g,io=0,p=1 -V  $sp.tmp.sh
done
