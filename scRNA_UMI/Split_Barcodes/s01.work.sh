#!/bin/bash
script=/Your/Path/s01.Barcode_UMI_QC_per1w_V2.pl
dir=/Your/Path/00.1.clean_data
mkdir -p $dir
perl $script Test_R1.fastq.gz Test_R2.fastq.gz Test.Info $dir
