meth_name=$1
ref=hg19
perl_exe=/usr/bin/perl
#bismark_exe=/WPS1/huboqiang/software/bismark_v0.7.6/bismark.origin
bismark_exe=/WPSnew/lilin/software/bismark_v0.7.6/bismark.origin
#bowtie_dir=/WPS1/huboqiang/software/bowtie-1.0.0
bowtie_dir=/WPSnew/lilin/software/bowtie-1.0.0
changeID_pl=/WPSnew/wangrui/bin/Share_bin/bin/Methylation/ChangeReadID.pl
trim_fq_dir=/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/00.1.trim_data
bam_dir=/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/01.bam
#database=/DBS/DB_temp/huboqiang_database/Database_Meth/$ref
database=/WPSnew/lilin/Database/MethGC/hg19
#samtools_exe=/WPS1/huboqiang/software/samtools-0.1.18/samtools
samtools_exe=/WPSnew/lilin/software/samtools-0.1.18/samtools

trim_fq1=${meth_name}_R1_val_1.fq.gz
trim_fq2=${meth_name}_R2_val_2.fq.gz

trim_sam_dir=$trim_fq_dir/$meth_name
bam_sam_dir=$bam_dir/$meth_name

sam=$bam_sam_dir/${trim_fq1}_bismark_pe.sam
unmap_fq1=$bam_sam_dir/${trim_fq1}_unmapped_reads_1.txt
unmap_fq2=$bam_sam_dir/${trim_fq2}_unmapped_reads_2.txt

sam1_unmap=$bam_sam_dir/unmap1/${trim_fq1}_unmapped_reads_1.txt_bismark
sam2_unmap=$bam_sam_dir/unmap2/${trim_fq2}_unmapped_reads_2.txt_bismark


$bismark_exe      --fastq    --non_directional   --unmapped                 \
    --phred33-quals --path_to_bowtie $bowtie_dir                            \
    --output_dir $bam_sam_dir --temp_dir $bam_sam_dir $database             \
    -1 $trim_sam_dir/$trim_fq1 -2 $trim_sam_dir/$trim_fq2                && \
    $samtools_exe view -u -b -S -t $database/${ref}_lambda.fa $sam         |\
    $samtools_exe sort -m 900000000 - $sam.sort


$bismark_exe      --fastq    --non_directional   --unmapped                 \
    --phred33-quals --path_to_bowtie $bowtie_dir                            \
    --output_dir $bam_sam_dir/unmap1 --temp_dir $bam_sam_dir/unmap1         \
    $database   $unmap_fq1                                               && \
    $samtools_exe view -uSb -t $database/${ref}_lambda.fa $sam1_unmap.sam  |\
    $samtools_exe sort -m 900000000 - $sam1_unmap.sort

$bismark_exe      --fastq    --non_directional   --unmapped                 \
    --phred33-quals --path_to_bowtie $bowtie_dir                            \
    --output_dir $bam_sam_dir/unmap2 --temp_dir $bam_sam_dir/unmap2         \
    $database   $unmap_fq2                                               && \
    $samtools_exe view -uSb -t $database/${ref}_lambda.fa $sam2_unmap.sam  |\
    $samtools_exe sort -m 900000000 - $sam2_unmap.sort

$perl_exe $changeID_pl $sam.sort.bam       $sam.sort.ReID.bam            && \
$samtools_exe rmdup    $sam.sort.ReID.bam                                   \
                       $sam.sort.ReID.rmdup.bam                          && \

$perl_exe $changeID_pl $sam1_unmap.sort.bam $sam1_unmap.sort.ReID.bam    && \
$samtools_exe rmdup -s $sam1_unmap.sort.ReID.bam                            \
                       $sam1_unmap.sort.ReID.rmdup.bam                   && \

$perl_exe $changeID_pl $sam2_unmap.sort.bam $sam2_unmap.sort.ReID.bam    && \
$samtools_exe rmdup -s $sam2_unmap.sort.ReID.bam                            \
                       $sam2_unmap.sort.ReID.rmdup.bam                   && \

$samtools_exe merge -f $bam_sam_dir/$meth_name.rmdup.bam                    \
                       $sam.sort.ReID.rmdup.bam                             \
                       $sam1_unmap.sort.ReID.rmdup.bam                      \
                       $sam2_unmap.sort.ReID.rmdup.bam                   && \
    
$samtools_exe sort -m 900000000  $bam_sam_dir/$meth_name.rmdup.bam          \
    $bam_sam_dir/$meth_name.sort.rmdup                                   && \

$samtools_exe index $bam_sam_dir/$meth_name.sort.rmdup.bam


rm  $sam1_unmap.sort.bam      $sam2_unmap.sort.bam                          \
    $sam1_unmap.sort.ReID.bam $sam2_unmap.sort.ReID.bam                     \
    $bam_sam_dir/*reads*txt   $bam_sam_dir/$meth_name.rmdup.bam             \
    $sam  $sam.sort.bam  $sam.sort.ReID.bam  $sam.sort.ReID.rmdup.bam       \
    $bam_sam_dir/unmap1/*fq.gz_unmapped_reads_1.txt_unmapped_reads.txt      \
    $bam_sam_dir/unmap2/*fq.gz_unmapped_reads_2.txt_unmapped_reads.txt      \
    $bam_sam_dir/unmap1/*.gz_unmapped_reads_1.txt_bismark.sort.ReID.rmdup.bam \
    $bam_sam_dir/unmap2/*.fq.gz_unmapped_reads_2.txt_bismark.sort.ReID.rmdup.bam \
    ${sam1_unmap}*sam ${sam2_unmap}*sam                     
#rm $trim_sam_dir/$trim_fq1 $trim_sam_dir/$trim_fq2
        
