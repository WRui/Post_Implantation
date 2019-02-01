#!/bin/bash
sample=$1
indir=/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/StatInfo/03.Tile_Meth/100bp_1X
outdir=/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/StatInfo/03.Tile_Meth/100bp_1X_Anno
annodir=/WPSnew/wangrui/Database/MethGC/hg19/sub_groups
region=$2

# region : ALR Alu CGI Enhancer ERV1 ERVK ERVL-MaLR ERVL Exon Intergenic Intragenic Intron L1 L2 LINE LTR MIR Promoter Promoter_HCP Promoter_ICP Promoter_LCP SINE SVA
annofile=$annodir/hg19.$region.xls
mkdir -p $outdir

cat $sample|while read sp
do
	mkdir -p $outdir/$sp
	echo "bedtools intersect -a $indir/$sp.100bp_1X.txt -b $annofile -u >$outdir/$sp/$sp.$region.100bp_1X.txt" >$sp.$region.tmp.sh
	qsub -cwd -l vf=3g,io=0,p=2 -V -p mem.q -P mem $sp.$region.tmp.sh
#	qsub -cwd -l vf=3g,io=0,p=2 -V -p urgent.q -P urgent  $sp.$region.tmp.sh
done
