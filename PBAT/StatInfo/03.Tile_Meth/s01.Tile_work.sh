#!/bin/bash
sample=$1
outdir=/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/StatInfo/03.Tile_Meth/300bp_1X
indir=/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/02.SingleC
mkdir -p $outdir
cat $sample|while read sp
do
#	echo "perl Tile_Meth_SingCVersion.pl $indir/$sp/$sp.SingleC.txt 100 $outdir/$sp.100bp_1X.txt 1 " > $sp.100.1X.tmp.sh
#	echo "perl Tile_Meth_SingCVersion.pl $indir/$sp/$sp.SingleC.txt 1000 $outdir/$sp.1000bp_1X.txt 1 " >$sp.1k.1X.tmp.sh
	echo "perl Tile_Meth_SingCVersion.pl $indir/$sp/$sp.SingleC.txt 300 $outdir/$sp.300bp_1X.txt 1 " >$sp.300.1X.tmp.sh
	qsub -cwd -l vf=8g,io=0,p=3 -q mem.q -P mem $sp.300.1X.tmp.sh
done
