#!/bin/bash
dir=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s06.XIC/02.bam
sp=$1
java=/WPSnew/wangrui/Software/java/jdk1.8.0_151/bin/java
picard=/WPSnew/wangrui/Software/
ref=/WPSnew/wangrui/Database/GATK/genome.fa
GATK=/WPSnew/lilin/software/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar
dbsnp=/WPSnew/wangrui/Database/Share_Database/Database/dbSNP/dbsnp_135.hg19.vcf
cat $sp|while read sample
do
    indir=$dir/$sample/chromosomes
    for chr in {1..22} X Y
    do
        echo "

# Single-sample GVCF calling on DNAseq with allele-specific annotations (for allele-specific cohort analysis workflow)
#https://software.broadinstitute.org/gatk/documentation/tooldocs/3.8-0/org_broadinstitute_gatk_tools_walkers_haplotypecaller_HaplotypeCaller.php

$java -Djava.io.tmpdir=$indir/chr$chr.TMP -Xmx6G -jar $GATK -T HaplotypeCaller -R $ref -I $indir/$sample.chr$chr.sort.RG.rmdups.realign.recal.bam -L chr$chr -D $dbsnp -G StandardAnnotation -ERC GVCF -o $indir/$sample.chr$chr.variants.AS.g.vcf

#UnifiedGenotyper
$java -Djava.io.tmpdir=$indir/chr$chr.TMP -Xmx6G -jar $GATK -T UnifiedGenotyper -R $ref -I $indir/$sample.chr$chr.sort.RG.rmdups.realign.recal.bam -L chr$chr -D $dbsnp --output_mode EMIT_ALL_SITES -o $indir/$sample.chr$chr.variants.UnifiedGenotyper.vcf 

		 " > $sample.chr$chr.SNP_withPhased.tmp.sh
		qsub -cwd -l vf=6g,io=0,p=3 -V $sample.chr$chr.SNP_withPhased.tmp.sh
	done
done
