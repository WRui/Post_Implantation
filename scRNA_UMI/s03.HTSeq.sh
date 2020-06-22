samp_name=$1
ref=$2
py_exe=/Software/anaconda/bin/python
samtools_exe=/Software/samtools-0.1.18/samtools
deseq_exe=/Software/anaconda/lib/python2.7/site-packages/HTSeq/scripts/count.py
umi_HTseq=/Software/anaconda/lib/python2.7/site-packages/RNA_UMI/bin/02_UMI_HTseq.py
TPM=/Software/anaconda/lib/python2.7/site-packages/RNA_UMI/bin/${ref}_tpm.py
tophat_dir=/01.Tophat
HTS_k_dir=/02.1.HTSeq_known
known_GTF=/Database/RNA_Database/hg19/refGene.gtf

export PYTHONPATH=/Software/anaconda/lib/python2.7/site-packages:$PYTHONPATH
$samtools_exe sort  -n -m 200000000                                        \
    $tophat_dir/$samp_name/accepted_hits.bam                               \
    $tophat_dir/$samp_name/accepted_hits.umi.sort

$samtools_exe view  -o                                                     \
    $tophat_dir/$samp_name/accepted_hits.umi.sort.sam                      \
    $tophat_dir/$samp_name/accepted_hits.umi.sort.bam 

[ ! -d $HTS_k_dir/$samp_name ] && mkdir -p $HTS_k_dir/$samp_name

$py_exe $deseq_exe                                                         \
    -s no -f sam -a 10                                                     \
    -o $tophat_dir/$samp_name/accepted_hits.umi.sort.gene.sam              \
    $tophat_dir/$samp_name/accepted_hits.umi.sort.sam  $known_GTF          \
    >$HTS_k_dir/$samp_name/$samp_name.dexseq.txt                         &&\

grep -v -P '^ERCC-|^RGC-|MIR|SNORD|Mir|Snord'                               \
    $HTS_k_dir/$samp_name/$samp_name.dexseq.txt                             \
    >$HTS_k_dir/$samp_name/$samp_name.dexseq_clean_gene.txt               &&\

grep -P '^ERCC-'                                                            \
    $HTS_k_dir/$samp_name/$samp_name.dexseq.txt                             \
    >$HTS_k_dir/$samp_name/$samp_name.dexseq_ERCC_RGCPloyA.txt              \

$py_exe $umi_HTseq $tophat_dir/$samp_name/accepted_hits.umi.sort.gene.sam  $HTS_k_dir/$samp_name/$samp_name.umi.txt

grep -v -P '^ERCC-|^RGC-|MIR|SNORD|Mir|Snord'                               \
    $HTS_k_dir/$samp_name/$samp_name.umi.txt                             \
    >$HTS_k_dir/$samp_name/$samp_name.umi_clean_gene.xls		          &&\
    
grep -P '^ERCC-|^RGC-'                                                      \
    $HTS_k_dir/$samp_name/$samp_name.umi.txt                             \
    >$HTS_k_dir/$samp_name/$samp_name.umi_clean_ERCC.xls	         # &&\

cat $HTS_k_dir/$samp_name/$samp_name.umi_clean_gene.xls $HTS_k_dir/$samp_name/$samp_name.umi_clean_ERCC.xls >$HTS_k_dir/$samp_name/$samp_name.umi_clean_gene_ERCC.xls

rm -f  $tophat_dir/$samp_name/accepted_hits.umi.sort.sam                      \
    $tophat_dir/$samp_name/accepted_hits.umi.sort.bam                      \
    $tophat_dir/$samp_name/accepted_hits.umi.sort.gene.sam                 \

$py_exe $TPM $HTS_k_dir/$samp_name/$samp_name.umi_clean_gene.xls $HTS_k_dir/$samp_name/$samp_name.umi_tpm_gene.xls $HTS_k_dir/$samp_name/$samp_name.umi_clean_gene_ERCC.xls $HTS_k_dir/$samp_name/$samp_name.umi_tpm_gene_ERCC.xls

        
