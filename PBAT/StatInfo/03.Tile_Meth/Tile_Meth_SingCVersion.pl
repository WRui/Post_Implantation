#!/bin/perl -w
## This script is used to calculate the Tile Methylation(CpG)
## Usage : perl $0 singlCpG.bed TileSize outfile sample
## WangRui 
## Latest Edition : 2016-4-14  
## Redited: 2016-4-15 add hg19.genome
## Redited: 20180904 add CpG group(seperate CpG and nonCG) && add read depth
use warnings;
use strict;
#open INDEX,$ARGV[0] or die "plese input *.fa.fai";
if (@ARGV != 4 ){
	print "Usage : perl $0 <SingleC_methLevel> <bin_length> <outfile> <depth>";
	exit;
}

open IN,$ARGV[0] or die "Please input SingleC file";## This is used for singleC.bed(for just CpG) file ,if original single C ,the col should minus 1
my $window = $ARGV[1];
open OUT,">$ARGV[2]" or die "Please input the outfile name";
#my $sample = $ARGV[3];
#open OUTnon, ">$ARGV[3]" or die "Please input the outfile name for nonCG sites";
my $Depth = $ARGV[3] ; #Add WR 180904
#$hg19 = "/WPSnew/wangrui/Database/hg19/hg19.genome";
#open (IN2,$ARGV[4]) or die "Please input hg19.genome"; #/datc/wangrui/Database/hg19/hg19.genom
#open (IN2,"$hg19") or die "Please input hg19.genome";
my %hash;
my %hash_non;
#while(<IN2>){
#	chomp;
#	my $Chr = (split /\s+/,$_)[0];
#	my $len = (split /\s+/,$_)[1];
#	my $win_number = int($len/$window);
#	$hash{$Chr}{$win_number} = "0\t0";
#}

#my %hash;
my ($start,$end);
while(<IN>){
	chomp;
	next if $_=~/#/;
	my @lines = split(/\s+/,$_);
	my($chr,$pos,$total,$meth,$ratio,$type)= ($lines[0],$lines[1],$lines[4],$lines[5],$lines[7],$lines[9]);
	next if ($total < $Depth);
	my $window_number = int($pos/$window);
	if(!exists $hash{$chr}{$window_number}){
		$hash{$chr}{$window_number} = "0\t0\t0\t0"; #[total_reads;meth_reads;meth_ratio_sum;CpG_number]
		$hash_non{$chr}{$window_number} = "0\t0\t0\t0"; #[total_reads;meth_reads;meth_ratio_sum;nonCG_number]
	}
	### CpG part 
	if($type =~ /CpG/){
		my @CpG_values = split(/\t/,$hash{$chr}{$window_number});
		my ($CG_total,$CG_meth,$CG_ratio,$CG_num) = ($CpG_values[0],$CpG_values[1],$CpG_values[2],$CpG_values[3]);
		$CG_total += $total;
		$CG_meth += $meth;
		$CG_ratio += $ratio;
		$CG_num += 1 ;
		$hash{$chr}{$window_number} = "$CG_total\t$CG_meth\t$CG_ratio\t$CG_num";

	}elsif($type =~ /CH[HG]/){
		my @nonCG_values = split(/\t/,$hash_non{$chr}{$window_number});
		my ($nonCG_total,$nonCG_meth,$nonCG_ratio,$nonCG_num) = ($nonCG_values[0],$nonCG_values[1],$nonCG_values[2],$nonCG_values[3]);
		$nonCG_total += $total;
		$nonCG_meth += $meth;
		$nonCG_ratio += $ratio;
		$nonCG_num += 1 ;
		$hash_non{$chr}{$window_number} = "$nonCG_total\t$nonCG_meth\t$nonCG_ratio\t$nonCG_num";
	}

}
#	if(exists $hash{$chr}{$window_number}){
#		my @value = split(/\t/,$hash{$chr}{$window_number});
#		$value[0]+=1;
#		$value[1]+=$meth;
		#$value[5]+=$TKO_meth;
		#$start = 1+$window*$window_number;
		#$end = $window*($window_number+1);
#		$hash{$chr}{$window_number}="$value[0]\t$value[1]";
#	}else{
#		#$start = 1+$window*$window_number;
		#$end = $window*($window_number+1);
#		$hash{$chr}{$window_number}="1\t$meth";
#	}	
#}

print OUT "#Chr\tStart\tEnd\tWindow_Number\tCpG_total\tCpG_meth\tCpG_ratio\tCpG_aveRatio\tCpG_num\tCH_total\tCH_meth\tCH_ratio\tCH_aveRatio\tCH_num\n";
my $average;
my $ave_ratio;
my $average_CH;
my $ave_ratio_CH;
my $big;
foreach my $key1(sort keys %hash){
	my $key2;
	foreach $key2(sort {$a<=>$b} keys %{$hash{$key1}}){
		$big = $key2;
	}
	foreach $key2(0,1,2...$big){
		$start = 1+$window*$key2;
		$end = $window*($key2+1);
		if(exists $hash{$key1}{$key2}){
		#print "$hash{$key1}{$key2}\n";
		my @words = split(/\t/,$hash{$key1}{$key2});
		my @words_CH = split(/\t/,$hash_non{$key1}{$key2});

		my ($nonCG_total,$nonCG_meth,$nonCG_ratio,$nonCG_num) = ($words_CH[0],$words_CH[1],$words_CH[2],$words_CH[3]);
		my ($CG_total,$CG_meth,$CG_ratio,$CG_num) = ($words[0],$words[1],$words[2],$words[3]);		
		
		next if ($CG_total eq 0 && $nonCG_total eq 0);

		$average = sprintf("%.3f" , $CG_total==0 ? "-1" : $CG_meth/$CG_total);
		$ave_ratio = sprintf("%.3f" , $CG_num==0 ? "-1" : $CG_ratio/$CG_num);
	
		$average_CH = sprintf("%.3f" , $nonCG_total==0 ? "-1" : $nonCG_meth/$nonCG_total) ;
		$ave_ratio_CH = sprintf("%.3f" ,  $nonCG_num==0 ? "-1" : $nonCG_ratio/$nonCG_num);
		
			#if($words[0]==0){
			#	$average = "NA";
		#	}else{
		#		$average = $words[1]/$words[0];
		#	}
		print OUT "$key1\t$start\t$end\t$key2\t$CG_total\t$CG_meth\t$average\t$ave_ratio\t$CG_num\t$nonCG_total\t$nonCG_meth\t$average_CH\t$ave_ratio_CH\t$nonCG_num\n";
		}
	}
}
