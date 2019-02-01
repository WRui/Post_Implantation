#!/bin/bash
dir=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s06.XIC
indir=$dir/02.bam
sample=$1
bamtools=/WPSnew/wangrui/Software/bamtools-master/build/usr/local/bin/bamtools
java=/WPSnew/wangrui/Software/java/jdk1.8.0_151/bin/java
picard=/WPSnew/wangrui/Software/picard-tools-1.130
cat $sample|while read patient
do
        #patient=`echo $sp|cut -d '_' -f 1`
		outdir=$indir/$patient/chromosomes
		for chr in {1..22} X Y
		do
		echo "
		rm -f $outdir/$patient.chr$chr.bam	
		# Step 1 : merge different lane same chromosome reads to single bam
		find $outdir -name \"*.chr$chr.bam\"	> $outdir/chr$chr.Bamlist
		echo \"chr$chr merge bam  begin at: \"\`date +%Y-%m-%d,%H:%M:%S\`
		$bamtools merge -list $outdir/chr$chr.Bamlist -out $outdir/$patient.chr$chr.bam
		 echo \"chr$chr merge bam  end at: \"\`date +%Y-%m-%d,%H:%M:%S\`		

		# Step 2 : Sort Merge Bam by picard-tools
		echo \"chr$chr Sort Bam begin at: \"\`date +%Y-%m-%d,%H:%M:%S\`
		$java -Djava.io.tmpdir=$outdir/chr$chr.TMP -Xmx10g -jar $picard/picard.jar SortSam I=$outdir/$patient.chr$chr.bam O=$outdir/$patient.chr$chr.sort.bam SORT_ORDER=coordinate VALIDATION_STRINGENCY=LENIENT VERBOSITY=ERROR TMP_DIR=$indir/chr$chr.TMP
		#$java -Djava.io.tmpdir=$outdir/chr$chr.TMP -Xmx10g -jar $picard/picard-1.119.jar SortSam I=$outdir/$patient.chr$chr.bam O=$outdir/$patient.chr$chr.sort.bam SORT_ORDER=coordinate VALIDATION_STRINGENCY=LENIENT VERBOSITY=ERROR TMP_DIR=$indir/chr$chr.TMP

		echo \"chr$chr Sort end at: \"\`date +%Y-%m-%d,%H:%M:%S\`
		" > $patient.chr$chr.mergeBam.tmp.sh
		qsub -cwd -l vf=3g,io=0,p=2 -V $patient.chr$chr.mergeBam.tmp.sh

		done
done
