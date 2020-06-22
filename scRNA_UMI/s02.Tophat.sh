samp_name=$1
brief_name=$2
data_dype=$3
tophat_py=/Path/to/tophat
cln_dir=/Output/Path/00.1.clean_data
tophat_dir=/Output/Path/01.Tophat
genome=/Database/RNA_Database/hg19/hg19_ERCC92_RGC
gtf_file=/Database/RNA_Database/hg19/refGene.gtf

if [ $data_dype == "1" ]
    then $tophat_py                                                         \
           -p 8 -G $gtf_file --library-type fr-unstranded                   \
           -o $tophat_dir/$brief_name  $genome                              \
           $cln_dir/$samp_name/$samp_name.R1.clean.fq.gz
fi
if [ $data_dype == "2" ]
    then $tophat_py                                                         \
           -p 8 -G $gtf_file --library-type fr-unstranded                   \
           -o $tophat_dir/$brief_name  $genome                              \
           $cln_dir/$samp_name/$samp_name.R1.clean.fq.gz $cln_dir/$samp_name/$samp_name.R2.clean.fq.gz
fi
        
