#!/bin/bash
sample=$1
script=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s07.FullLengthRNA/bin/s02.RNA_SNP.sh
inpath=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s07.FullLengthRNA/02.Tophat
outpath=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s07.FullLengthRNA/06.SNP_Calling
mkdir -p $outpath
cat $sample|while read sp
do
	echo "bash $script $inpath $sp $outpath" >$sp.SNP.tmp.sh
	qsub -cwd -l vf=2g,io=0,p=1 -V  $sp.SNP.tmp.sh
done
