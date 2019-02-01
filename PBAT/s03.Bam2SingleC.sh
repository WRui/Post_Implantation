#!/bin/bash
ref=/WPSnew/lilin/Database/MethGC/hg19/hg19_lambda.fa
script=/WPSnew/wangrui/bin/Share_bin/bin/Methylation/bin/singleC_metLevel.hg19.pl
SANTOOLS=/WPSnew/wangrui/Software/samtools-0.1.18/samtools
sample=$1
indir=/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/01.bam
outdir=/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/02.SingleC
cat $sample|while read sp
do
	mkdir -p $outdir/$sp
	bam=$indir/$sp/$sp.sort.rmdup.bam
	
	singleC_tmp=$outdir/$sp/$sp.SingleC_tmp.txt
	singleC_lambda=$outdir/$sp/$sp.lambda.SingleC.txt
	singleC_chrM=$outdir/$sp/$sp.chrM.SingleC.txt
	singleC=$outdir/$sp/$sp.SingleC.txt
	echo "
	
$SANTOOLS view -h $bam \
| $SANTOOLS view -uSb  /dev/stdin \
| $SANTOOLS  mpileup -O -f $ref /dev/stdin >$bam.pileup

perl $script $bam.pileup >$singleC_tmp

grep \"lambda\" $singleC_tmp >$singleC_lambda
grep \"chrM\" $singleC_tmp >$singleC_chrM
grep -v \"lambda\" $singleC_tmp |grep -v \"chrM\"  >$singleC

rm $singleC_tmp
rm $bam.pileup

" > Bam2C_old.$sp.tmp.sh
qsub -cwd -l vf=10g,io=0,p=5 -V Bam2C_old.$sp.tmp.sh
done
