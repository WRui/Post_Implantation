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
## Extract SNP Variant
echo \"chr$chr extract SNP calling begin at:  \" \`date +%Y-%m-%d,%H:%M:%S\`

$java -Djava.io.tmpdir=$indir/chr$chr.TMP -Xmx4g -jar $GATK -T SelectVariants -R $ref -L chr$chr -selectType SNP -V $indir/$sample.chr$chr.variants.vcf -o $indir/$sample.chr$chr.snp.vcf

## Extract Indel

echo \"chr$chr extract Indel calling begin at:  \" \`date +%Y-%m-%d,%H:%M:%S\`
 $java -Djava.io.tmpdir=$indir/chr$chr.TMP -Xmx4g -jar $GATK -T SelectVariants -R $ref -L chr$chr -selectType INDEL -V $indir/$sample.chr$chr.variants.vcf -o $indir/$sample.chr$chr.indel.vcf

## Variant Filtration 

echo \"chr$chr Filter Variant SNP  begin at:  \" \`date +%Y-%m-%d,%H:%M:%S\`

$java -Djava.io.tmpdir=$indir/chr$chr.TMP -Xmx4g -jar $GATK -T VariantFiltration -R $ref -V $indir/$sample.chr$chr.snp.vcf --filterExpression \"QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0\" --filterName \"GATK_SNP_Filter\" -o $indir/$sample.chr$chr.snp.gatkFiltered.vcf

$java -Djava.io.tmpdir=$indir/chr$chr.TMP -Xmx4g -jar $GATK -T VariantFiltration -R $ref -V $indir/$sample.chr$chr.indel.vcf --filterExpression \"QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0\" --filterName \"GATK_SNP_Filter\"  -o $indir/$sample.chr$chr.idel.gatkFiltered.vcf

"	 > $sample.chr$chr.ExtractFilterVariant.tmp.sh
	
	qsub -cwd -l vf=4g,io=0,p=3 -V $sample.chr$chr.ExtractFilterVariant.tmp.sh
	
	done
done

