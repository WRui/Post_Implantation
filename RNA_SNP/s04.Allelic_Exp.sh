#!/bin/bash
script=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s07.FullLengthRNA/bin/SNP_Phased.pl
dir=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s07.FullLengthRNA/07.PhasedResult
mkdir -p $dir
sample=$1
#sperm4_DNA
# maternal : volun3_DNA volunteer11_aoxuemei volunteer12_tangyuxia Volunter13 Volunter14 $sp.All.g.vcf
cat $sample|while read sp
do
	mkdir -p $dir/$sp
	echo "perl $script $dir/$sp/$sp.add_parent_SNP_All_dep0.txt $dir/$sp/$sp.Phased_Dep0.txt $dir/$sp/$sp.chrX_Dep0.txt $sp " >${sp}_addRatio.tmp_dep2.sh
	qsub -cwd -l vf=1g,io=0,p=1 -V ${sp}_addRatio.tmp_dep2.sh
done 
