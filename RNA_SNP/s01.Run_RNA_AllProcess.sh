#!/bin/bash
inpath=$1
sp=$2

echo "NOTE: This script is used for human hg19, if use for other organist, please change ref-genome gtf and bed file."
echo "the inpath is $inpath"
echo "the running sample  is $sp"
gtf=/WPSnew/wangrui/Database/Share_Database/Database/gtf_files/hg19_refGene/hg19_ERCC92_RGC_refGene.gtf
genome=/WPSnew/wangrui/Database/bowtie2_index/hg19_ERCC92_RGC/hg19_ERCC92_RGC
QC_script=/WPSnew/wangrui/bin/QC/QC_plus_rm_primer_polyA_T_trimTSO.pl


if [ $# -ne 2 ] ; then
    echo "Usage: bash $0 RootInpath BatchName SampleFilePath"
    exit
fi

function do_mkdir {
	mkdir -p $inpath/01.clean_data
	mkdir -p $inpath/02.Tophat
	mkdir -p $inpath/03.Cuffquant
	mkdir -p $inpath/04.Cuffnorm
	mkdir -p $inpath/StatInfo
	mkdir -p $inpath/StatInfo/00.Info
	mkdir -p $inpath/scripts
	mkdir -p $inpath/scripts/tmp
	
}

function do_QC {
sp=$1
perl $QC_script --indir $inpath/00.raw_data --outdir $inpath/01.clean_data --sample $sp --end 2 --scRNA 1 
}

function do_Tophat {
sp=$1
mkdir -p $inpath/02.Tophat/$sp

tophat -p 3 -G $gtf -o $inpath/02.Tophat/$sp --library-type fr-unstranded $genome $inpath/01.clean_data/$sp/${sp}.R1.clean.fq.gz $inpath/01.clean_data/$sp/${sp}.R2.clean.fq.gz
}

function do_Degradation {
echo "
#!/bin/bash
mkdir -p $inpath/01.Tophat/sample_name
sample=$sample
#bed_file=/Share/BP/wangrui/Database/bed_file/hg19/human/hg19_RefSeq.bed
bed_file=/WPSnew/wangrui/Database/hg19/hg19_RefSeq.bed
mkdir -p $inpath/StatInfo/00.Info/s02.chr_coverage/Seperate
cat \$sample|while read sp
do
	echo \"
    ln -s $inpath/01.Tophat/\$sp/accepted_hits.bam $inpath/01.Tophat/sample_name/\$sp.bam  && \\
	 /Share/BP/yanglu/software/samtools-1.2/samtools index $inpath/01.Tophat/$batch/sample_name/\$sp.bam &&  \\
	/Share/BP/yanglu/software/samtools-1.2/samtools idxstats $inpath/01.Tophat/sample_name/\$sp.bam|grep -v '*'|sort -k 1.4n >$inpath/StatInfo/00.Info/s02.chr_coverage/Seperate/\${sp}.chr_coverage.txt
 \" >$inpath/scripts/tmp/\${sp}.degredation.tmp.sh
	qsub -cwd -l vf=1g -V $inpath/scripts/tmp/\${sp}.degredation.tmp.sh
done
" >$inpath/scripts/s03.1.Degradation.sh

echo "
#!/bin/bash
#bed_file=/Share/BP/wangrui/Database/bed_file/hg19/human/hg19_RefSeq.bed
bed_file=/WPSnew/wangrui/Database/hg19/hg19_RefSeq.bed
mkdir -p $inpath/StatInfo/00.Info/s01.Degradation
geneBody_coverage.py -r \$bed_file  -i $inpath/01.Tophat/sample_name/ -o $inpath/StatInfo/00.Info/s01.Degradation/Degradation
" > $inpath/scripts/s03.2.Degradation.sh

}

function do_cuffquant {
sp=$1
    mkdir -p $inpath/03.Cuffquant/$sp
	cuffquant -o $inpath/03.Cuffquant/$sp -p 5 $gtf  $inpath/02.Tophat/$sp/accepted_hits.bam

}

function do_cuffnorm {
sample=$1
echo -e \"Sample\tGroup\" >$inpath/scripts/sample_table.txt
ls -1 $inpath/02.Tophat/sample_name/*.bam >$inpath/scripts/sample.tmp.txt
paste  $inpath/scripts/sample.tmp.txt $sample  >>$inpath/scripts/sample_table.txt
sample_table=$inpath/scripts/sample_table.txt
cuffnorm -p 10 --use-sample-sheet -o $inpath/04.Cuffnorm/cuffnorm_Result $gtf $sample_table
}



function do_HTSeq {
sp=$1
mkdir -p $inpath/05.HTSeq/$sp

unset PYTHONPATH
export PYTHONPATH=/WPSnew/wangrui/Software/anaconda/lib/python2.7/site-packages:$PYTHONPATH
export PATH=/WPSnew/wangrui/Software/anaconda/bin:$PATH

py_exe=/WPSnew/wangrui/Software/anaconda/bin/python
deseq_exe=/WPSnew/wangrui/Software/anaconda/lib/python2.7/site-packages/HTSeq/scripts/count.py
/WPSnew/wangrui/Software/samtools-1.8/samtools view -F 4 $inpath/02.Tophat/$sp/accepted_hits.bam| $py_exe $deseq_exe - -s no -f sam -a 10 -o $inpath/02.Tophat/$sp/accepted_hits.umi.sort.sam $gtf  > $inpath/05.HTSeq/$sp/$sp.htseq.out && grep -v -P '^ERCC-|^RGC-|MIR|SNORD|Mir|Snord' $inpath/05.HTSeq/$sp/$sp.htseq.out >$inpath/05.HTSeq/$sp/$sp.htseq_clean.out
}

do_mkdir	
do_QC $sp
do_Tophat $sp
do_cuffquant $sp
do_HTSeq  $sp

