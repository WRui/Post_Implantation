#!/bin/bash
script=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s07.FullLengthRNA/bin/Merge_Trio_gVCF_V2.pl
parent_dir=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s06.XIC/02.bam
child_dir=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s07.FullLengthRNA/06.SNP_Calling
outdir=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s07.FullLengthRNA/07.PhasedResult
mkdir -p $outdir
sample=$1
maternal=$2
#sperm4_DNA
# maternal : volun3_DNA volunteer11_aoxuemei volunteer12_tangyuxia Volunter13 Volunter14 $sp.All.g.vcf
cat $sample|while read sp
do
	mkdir -p $outdir/$sp
	echo "perl $script $child_dir/$sp/${sp}.variants_result.AS.g.vcf $parent_dir/sperm4_DNA/sperm4_DNA.All.g.vcf $parent_dir/$maternal/${maternal}.All.g.vcf 1 $outdir/$sp/$sp.add_parent_SNP_All_dep0.txt" > ${sp}_Phased_new_Dep0.tmp.sh
	qsub -cwd -l vf=3g,io=0,p=1 -V ${sp}_Phased_new_Dep0.tmp.sh
done 
