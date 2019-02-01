#!/bin/bash
dir=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s06.XIC/02.bam
sp=$1
java=/WPSnew/wangrui/Software/java/jdk1.8.0_151/bin/java
picard=/WPSnew/wangrui/Software
ref=/WPSnew/wangrui/Database/GATK/genome.fa
GATK=/WPSnew/lilin/software/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar
Indel_vcf=/WPSnew/wangrui/Database/indel_annotation/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf

cat $sp|while read sample
do
	indir=$dir/$sample/chromosomes
	for chr in {1..22} X Y
	do
		echo "




# Add Read Groups
echo \"chr$chr Add read groups begin at: \" \`date +%Y-%m-%d,%H:%M:%S\`
#rm -f $indir/$sample.chr$chr.sort.RG.bam

$java -Djava.io.tmpdir=$indir/chr$chr.TMP -Xmx10g -jar $picard/picard.jar AddOrReplaceReadGroups  I=$indir/$sample.chr$chr.sort.bam O=$indir/$sample.chr$chr.sort.RG.bam RGID=$sample RGLB=$sample RGPL=illumina RGPU=$sample RGSM=$sample TMP_DIR=$indir/chr$chr.TMP SORT_ORDER=coordinate VALIDATION_STRINGENCY=LENIENT VERBOSITY=ERROR


			
echo \"chr$chr Add read groups end at: \" \`date +%Y-%m-%d,%H:%M:%S\`			
		
# Remove PCR duplocation
echo \"chr$chr Remove PCR duplication begin at: \" \`date +%Y-%m-%d,%H:%M:%S\`
rm -f $indir/$sample.chr$chr.sort.RG.rmdups.bam

$java -Djava.io.tmpdir=$indir/chr$chr.TMP -Xmx10g -jar $picard/picard.jar MarkDuplicates I=$indir/$sample.chr$chr.sort.RG.bam O=$indir/$sample.chr$chr.sort.RG.rmdups.bam METRICS_FILE=$indir/$sample.chr$chr.sort.RG.rmdups.metric.txt REMOVE_DUPLICATES=true ASSUME_SORTED=true VERBOSITY=ERROR CREATE_INDEX=true TMP_DIR=$indir/chr$chr.TMP VALIDATION_STRINGENCY=LENIENT


echo \"chr$chr Remove PCR duplication end  at: \" \`date +%Y-%m-%d,%H:%M:%S\`

			
# Indel Realignment
echo \"chr$chr Indel realignment begin at: \" \`date +%Y-%m-%d,%H:%M:%S\`
#rm -f $indir/$sample.chr$chr.intervals			

$java -Djava.io.tmpdir=$indir/chr$chr.TMP -Xmx10G -jar $GATK -T RealignerTargetCreator -R $ref -I $indir/$sample.chr$chr.sort.RG.rmdups.bam -o $indir/$sample.chr$chr.intervals --known $Indel_vcf			

## IndelRealigner
echo \"chr$chr IndelRealigner begin at: \" \`date +%Y-%m-%d,%H:%M:%S\`
#rm -f $indir/$sample.chr$chr.sort.RG.rmdups.realign.bam

$java -Djava.io.tmpdir=$indir/chr$chr.TMP -Xmx10G -jar $GATK -T IndelRealigner -R $ref -I $indir/$sample.chr$chr.sort.RG.rmdups.bam --targetIntervals $indir/$sample.chr$chr.intervals -o $indir/$sample.chr$chr.sort.RG.rmdups.realign.bam -known $Indel_vcf -LOD 0.4

## BaseRecalibrator
echo \"chr$chr BaseRecalibrator begin at: \" \`date +%Y-%m-%d,%H:%M:%S\`
#rm -f $indir/$sample.chr$chr.recal_data.grp

$java -Djava.io.tmpdir=$indir/chr$chr.TMP -Xmx6G -jar $GATK -T BaseRecalibrator  -R $ref  -I $indir/$sample.chr$chr.sort.RG.rmdups.realign.bam -knownSites /WPSnew/wangrui/Database/dbSNP/dbsnp_135.hg19.vcf -o $indir/$sample.chr$chr.recal_data.grp

## PrintReads
echo \"chr$chr PrintReads begin at: \" \`date +%Y-%m-%d,%H:%M:%S\`
#rm -f $indir/$sample.chr$chr.sort.RG.rmdups.realign.recal.bam
$java -Djava.io.tmpdir=$indir/chr$chr.TMP -Xmx10G -jar $GATK -T PrintReads -R $ref -I $indir/$sample.chr$chr.sort.RG.rmdups.realign.bam -BQSR $indir/$sample.chr$chr.recal_data.grp   -o $indir/$sample.chr$chr.sort.RG.rmdups.realign.recal.bam

echo \"chr$chr Indel realignment end at: \" \`date +%Y-%m-%d,%H:%M:%S\`

##HaplotypeCaller

$java -Djava.io.tmpdir=$indir/chr$chr.TMP -Xmx10G -jar $GATK -T HaplotypeCaller -R $ref -I $indir/$sample.chr$chr.sort.RG.rmdups.realign.recal.bam -L chr$chr -D /WPSnew/wangrui/Database/Share_Database/Database/dbSNP/dbsnp_135.hg19.vcf --genotyping_mode DISCOVERY  -stand_emit_conf 10 -stand_call_conf 30 -o $indir/$sample.chr$chr.variants.vcf

echo \"chr$chr variants calling end at: \" \`date +%Y-%m-%d,%H:%M:%S\`

		" > $sample.chr$chr.AddRG_rmDup_IndelRealignment.tmp.sh
	qsub -cwd -l vf=6g,io=0,p=3 -V $sample.chr$chr.AddRG_rmDup_IndelRealignment.tmp.sh
	done
done


