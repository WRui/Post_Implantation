#!/bin/bash
dir=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s06.XIC/02.bam
sp=$1
java=/WPSnew/wangrui/Software/java/jdk1.8.0_151/bin/java
picard=/WPSnew/wangrui/Software
ref=/WPSnew/wangrui/Database/GATK/genome.fa
GATK=/WPSnew/lilin/software/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar

cat $sp|while read sample
do
    indir=$dir/$sample/chromosomes
    for chr in {1..22} X Y
    do
        echo "
echo \"chr$chr	convert to Table begion at: \`date +%Y-%m-%d,%H:%M:%S\`\"
$java -Djava.io.tmpdir=$indir/chr$chr.TMP -Xmx4G -jar $GATK -T VariantsToTable -R $ref -V $indir/$sample.chr$chr.snp.gatkFiltered.vcf -F CHROM -F POS -F REF -F ID -F QUAL -F FILTER -GF DP -GF AD -GF GT -GF GQ --showFiltered  -o $indir/$sample.chr$chr.snp.gatkFiltered.table

## Filter SNP table 
perl FilterSNP.GATK.pl	$indir/$sample.chr$chr.snp.gatkFiltered.table > $indir/$sample.chr$chr.snp.gatkFiltered.table.Filtered

perl table.filterDP_heteroMinor.pl $indir/$sample.chr$chr.snp.gatkFiltered.table.Filtered > $indir/$sample.chr$chr.snp.gatkFiltered.table.Filtered.DP8-200_filter
#mv $indir/$sample.chr$chr.snp.gatkFiltered.table.Filtered.DP5-200_filter $indir/$sample.chr$chr.snp.gatkFiltered.table.Filtered.DP8-200_filter
" > $sample.chr$chr.VariantsToTable.tmp.sh
qsub -cwd -l vf=4g,io=0,p=2 -V $sample.chr$chr.VariantsToTable.tmp.sh
#bash $sample.chr$chr.VariantsToTable.tmp.sh
	done
done
