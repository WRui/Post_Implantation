#!/bin/bash
dir=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s06.XIC
indir=$dir/00.split_fastq
split_files=$1

#cat $R1_files| while read sp; do echo ${sp}_R1.fastq.gz|eval tmp='s/R1_split_//g'; mv ${sp} $tmp ;done
`awk -F '_' -v OFS="" '{print "sh\trename.sh\t",$0,"\t",$1,"_",$4,"_",$2,".fastq","\t",$1,"_",$4}' $split_files > rename_work.sh`


#cat $R1_files|while read sp
#do
#	mv $indir/$sp $indir/${sp}_R1.fastq.gz 
#done

#cat $R2_files|while read sp
#do
#	mv $indir/$sp $indir/${sp}_R2.fastq.gz
#done


