#!/bin/bash
sample=$1
indir=/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/StatInfo/03.Tile_Meth/100bp_1X_Anno
outdir=/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/StatInfo/03.Tile_Meth/100bp_1X_Meth

mkdir -p  $outdir
cat $sample|while read sp
do
	inpath=$indir/$sp
	echo "Rscript Region_Ave_MethRatio.R $inpath $outdir" >$sp.RegionMeth.tmp.sh
	qsub -cwd -l vf=4g,io=0,p=2 -V $sp.RegionMeth.tmp.sh
done
