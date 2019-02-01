#!usr/bin/perl -w
use strict;
use warnings;
#open IN,"$ARGV[0]" or die $!;
open OUT,">$ARGV[0]" or die $!;
my $path=$ARGV[1];
#@filelist=glob '/datc/wangrui/Project/Tet123_KO/RRBS/20150715/';
print OUT "Sample\tTotal_bases(Gb)\tTotal_reads\tReads_After_trim\tUniq_mapping reads\tMapping_ratio\tConversion_ratio\n";
my $i=0;
my @raw_reads;
my @raw_bases;
my @trim_reads;
my @uniq_mapping;
#my @mapping_ratio;
my $line;
my @name;
my %name_string;
my $file;
my @filename;
my $j;
my (@total,@unmeth);
my (@data,@data0,@data2,@data3,@data4,@lines);
my @trim_file_list = glob "$path/00.1.trim_data/*/*_R2*_trimming_report.txt";
foreach $file(@trim_file_list){
	@filename=split(/\//,$file);
	#print $i;
	#print "$file\n";
	$name[$i]=$filename[-2];
	$name_string{"$filename[-2]"} = $i;
	open(FH,$file) or die $!;
	while (<FH>){
		chomp;
		$line=$_;
		if ($line=~/Processed reads:/)
		{
			@data=split(/:/,$line);
			$raw_reads[$i]=$data[1]*2;
		#	print $raw_reads[$i],"\n";
			
		}
		if ($line=~/Processed bases:/)
		{
			@data2=split(/:/,$line);
			#my @tmp=split $data2[1];
			#print $data2[0],"\n";
			my $second=$data2[1];
			my @tmp=split(/bp/,$second);
			$raw_bases[$i]=$tmp[0]*2/1000000000;
		#	print $raw_bases[$i],"\n";
		}
	}
	$i++;
	close FH;
}

$i=0;

my @mapping_report=glob "$path/01.bam/*/*Bismark_paired-end_mapping_report.txt";

foreach $file(@mapping_report){
	my @filename=split(/\//,$file);
	#$name[$i]=$filename2[-2];
	my $j = $name_string{"$filename[-2]"};
	
	open(IN2,$file) or die $!;
	#print $i;
	while(<IN2>){
		chomp;
		$line=$_;
		if ($line=~/Sequence pairs analysed in total:/){
			@data0=split(/:/, $line);
			
			#$trim_reads[$i]=$data0[1]*2;
			$trim_reads[$j] = $data0[1]*2;
			#print $trim_reads[$i];
		}
		if($line=~/Number of paired-end alignments with a unique best hit:/)
		{
			@data3=split(/:/, $line);
			#$uniq_mapping[$i]=$data3[1]*2;
			$uniq_mapping[$j] = $data3[1]*2;
	#		print $uniq_mapping[$i],"\n";
		}
#		if($line=~/Mapping efficiency:/)
#		{
#			@data4=split(/:/, $line);
#			$mapping_ratio[$i]=$data4[1];
			#print @mapping_ratio;
#		}	
	}
	#close IN2;
	$i++;
	#print $i,"\n";
	#close IN2；
}
#my $j;

my (@unmap1_1,@unmap1_2,@unmap1_reads,@unmap1_uniq);
$i=0;
my @unmap1_file= glob "$path/01.bam/*/unmap1/*mapping_report.txt";
foreach $file(@unmap1_file){
	open(IN4,$file) or die $!;

	 my @filename=split(/\//,$file);
     my $j = $name_string{"$filename[-3]"};
	 #print $j;
	while(<IN4>){
		chomp;
		$line=$_;
		if ($line=~/Sequences analysed in total:/){
			@unmap1_1=split(/:/,$line);
			#$unmap1_reads[$i]=$unmap1_1[1];
			$unmap1_reads[$j]=$unmap1_1[1];
	#		print $unmap1_reads[$i],"\n";
		}
		if ($line=~/Number of alignments with a unique best hit from the different alignments:/)
		{
			@unmap1_2=split(/:/,$line);
			#$unmap1_uniq[$i]=$unmap1_2[1];
			$unmap1_uniq[$j]=$unmap1_2[1];
		}
	}
	$i++;
	#print $i,"\n";
}


#my (@unmap1_1,@unmap1_2,@unmap1_reads,@unmap1_uniq);
my (@unmap2_1,@unmap2_2,@unmap2_reads,@unmap2_uniq);
$i=0;
my @unmap2_file= glob "$path/01.bam/*/unmap2/*mapping_report.txt";
foreach $file(@unmap2_file){
        open(IN5,$file) or die $!;

		my @filename=split(/\//,$file);
		my $j = $name_string{"$filename[-3]"};

        while(<IN5>){
                chomp;
                $line=$_;
                if ($line=~/Sequences analysed in total:/){
                        @unmap2_1=split(/:/,$line);
                        #$unmap2_reads[$i]=$unmap2_1[1];
                        $unmap2_reads[$j]=$unmap2_1[1];
                }
                if ($line=~/Number of alignments with a unique best hit from the different alignments:/)
                {
                        @unmap2_2=split(/:/,$line);
                        #$unmap2_uniq[$i]=$unmap2_2[1];
                        $unmap2_uniq[$j]=$unmap2_2[1];
                }
        }
        $i++;
#	print $i,"\n";
}



$i=0;
my @lammda_SingleC=glob "$path/02.SingleC/*/*lambda.SingleC.txt";
foreach $file(@lammda_SingleC){
	open (IN3,$file) or die $!;
	
	my @filename=split(/\//,$file);
	my $j = $name_string{"$filename[-2]"};

#	print "$file\n";
	while(<IN3>){
		chomp;
		$line=$_;
		@lines=split(/\s+/,$line);
#		print $lines[9];
		#if($lines[3]=~/CH[HG]/){
			#$total[$i]+=$lines[4];
			$total[$j]+=$lines[4];
			#print $total[$i],"\t";
#			$unmeth[$i]+=$lines[6]; # not unmeth is meth reads for CGmaptools
			$unmeth[$j]+=$lines[6];
			#print "$unmeth[$i] ";
	#	}
	}
	$i++;
#	print $i;
}


#print $i;
#print "$unmeth[0] ";
#print $total[0];
#print $unmeth[0]/$total[0];

for($j=0;$j<$i;$j++){
#	print $j,"\n";
	my ($conversion,$mapping_ratio);
	if(exists $total[$j]){
		#$conversion = "NA";
		$conversion = $unmeth[$j]/$total[$j];
	}else{
#		$conversion = $unmeth[$j]/$total[$j]; #
		$conversion = "NA";		
	}
	my $total_mapping;
	if((exists $unmap1_uniq[$j]) && (exists $unmap2_uniq[$j]) && (exists $uniq_mapping[$j])){
		$total_mapping=$unmap1_uniq[$j]+$unmap2_uniq[$j]+$uniq_mapping[$j];
	}else{
		$total_mapping = "NA";
	}
	#my $total_mapping=$unmap1_uniq[$j]+$unmap2_uniq[$j]+$uniq_mapping[$j];
#	print "KOOK $trim_reads[$j]\n";
#	print "$trim_reads[$j]\n";
	if(exists $trim_reads[$j] && $trim_reads[$j]!=0 && $total_mapping ne "NA"){
		#$mapping_ratio= "NA";
		$mapping_ratio=$total_mapping/$trim_reads[$j];
	}else{
		#$mapping_ratio=$total_mapping/$trim_reads[$j];
		$mapping_ratio= "NA";
	}
	print OUT "$name[$j]\t$raw_bases[$j]\t$raw_reads[$j]\t$trim_reads[$j]\t$total_mapping\t$mapping_ratio\t$conversion\n";
}
