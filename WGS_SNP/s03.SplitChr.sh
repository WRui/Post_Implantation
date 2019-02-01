#!/bin/bash
dir=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s06.XIC
indir=$dir/02.bam
sample=$1
bamtools=/WPSnew/wangrui/Software/bamtools-master/build/usr/local/bin/bamtools
cat $sample|while read sp
do
	patient=`echo $sp|cut -d '_' -f 1`
	lane=`echo $sp|cut -d '_' -f 2 `
	#echo "$patient    $lane"
	mkdir -p $indir/$patient
	mkdir -p $indir/$patient/chromosomes
	outdir=$indir/$patient/chromosomes
	echo "
	ln -s $indir/$sp.bam $outdir/$sp.bam
	$bamtools split -reference -refPrefix . -in $outdir/$sp.bam
	echo \"Split end at: \" \`date +%Y-%m-%d,%H:%M:%S\`
	" >$sp.splitChr.tmp.sh
	qsub -cwd -l vf=2g,io=0,p=1 -V $sp.splitChr.tmp.sh
done
