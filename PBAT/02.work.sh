#!/bin/bash
sample=$1
dir=/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/01.bam
mkdir -p $dir
cat $sample|while read sp
do
	mkdir -p $dir/$sp
	echo "bash s02.Bismark.sh $sp" >$sp.bismark.tmp.sh
#	qsub -cwd -l vf=25g,io=0,p=7 -q mem.q -P mem -V $sp.bismark.tmp.sh
	qsub -cwd -l vf=25g,io=0,p=7 -V $sp.bismark.tmp.sh
done
