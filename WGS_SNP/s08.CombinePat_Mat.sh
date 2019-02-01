#!/bin/bash
pat=sperm4_DNA
dir=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s06.XIC
sp=$1
#sp=AllPatient.txt
mkdir -p $dir/s03.pat_mat_snp
cat $sp|while read sample
do
    indir=$dir/02.bam/$sample/chromosomes
	outdir=$dir/s03.pat_mat_snp/$sample
	mkdir -p $outdir
    for chr in {1..22} X Y
    do
echo "
	perl combine_pat-mat.pl $dir/02.bam/$pat/chromosomes/$pat.chr$chr.snp.gatkFiltered.table.Filtered.DP8-200_filter $indir/$sample.chr$chr.snp.gatkFiltered.table.Filtered.DP8-200_filter >$outdir/chr$chr.snp.gatkFiltered.DP_filter.pat_mat
	perl pat_mat-distingish.SNP.pl $outdir/chr$chr.snp.gatkFiltered.DP_filter.pat_mat >$outdir/chr$chr.final.pat_mat.xls

" > $sample.chr$chr.Combine.tmp.sh
qsub -cwd -l vf=2g,io=0,p=1 -V $sample.chr$chr.Combine.tmp.sh
	done
done

