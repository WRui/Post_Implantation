#dir=`pwd`

dir=/WPSnew/wangrui/Project/Post_Implantation/Human/FurtherAnalysis/s06.XIC/00.split_fastq
old=$1
fq=$2
new=$3
#sample=s-20180412-Exon-1_HL577CCXY_L8
if [ ! -d $dir/$new ]
   then mkdir $dir/$new
fi

mv  $dir/$old $dir/$new

mv $dir/$new/$old $dir/$new/$fq
gzip $dir/$new/$fq
#mv $dir/$new/$old $dir/$new/$new\_R2.fastq.gz

