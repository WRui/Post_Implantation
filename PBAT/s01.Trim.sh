#!/bin/bash
sampleList=$1
#trim_galore=/WPS1/huboqiang/bin/trim_galore
trim_galore=/WPSnew/wangrui/Software/TrimGalore-0.5.0/trim_galore
dir=/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT
cat $sampleList| while read sp
do
	mkdir -p $dir/00.1.trim_data/$sp
	echo " $trim_galore  --quality 20 --stringency 3 --length 50 --clip_R1 9 --clip_R2 9  --paired --trim1 --phred33 --gzip  --output_dir $dir/00.1.trim_data/$sp $dir/00.0.raw_data/$sp/${sp}_R1.fastq.gz $dir/00.0.raw_data/$sp/${sp}_R2.fastq.gz " > $sp.trim.tmp.sh
	qsub -cwd -l vf=3g,io=0,p=3 -V $sp.trim.tmp.sh
done
