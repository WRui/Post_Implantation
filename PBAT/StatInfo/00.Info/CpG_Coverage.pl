#!/usr/bin/perl -w
use strict;
use warnings;
my $file=$ARGV[0];
open OUT,">$ARGV[1]" or die $!;
print OUT "Sample\tTotalCpGs(1X)\tTotalUnique(1X)\tMeanCov(1X)\tTotalCpGs(3X)\tTotalUnique(3X)\tMeanCov(3X)\tTotalCpGs(5X)\tTotalUnique(5X)\tMeanCov(5X)\tTotalCpGs(10X)\tTotalUnique(10X)\tMeanCov(10X)\n";


my @depth=(1,3,5,10);
my $length=@depth;
my (@sum,@num,$name);
my $j;

open(FH,"gzip -dc $file |") or die "fail open the file";
while(<FH>){
	chomp;
	my $line=$_;
	next if ($line =~/#/);
	next if ($line =~/lambda/);
	my @words=split(/\s+/,$line);
	for($j=0;$j<$length;$j++){
		if($words[7]>=$depth[$j] && $words[9]=~/CpG/){
			$sum[$j]+=$words[4];
			$num[$j]++;
		}
	}
}


my $ratio_1 = $sum[0]/$num[0];
my $ratio_3 = $sum[1]/$num[1];
my $ratio_5 =  $sum[2]/$num[2];
my $ratio_10 = $sum[3]/$num[3];
print OUT "$name\t$sum[0]\t$num[0]\t$ratio_1\t$sum[1]\t$num[1]\t$ratio_3\t$sum[2]\t$num[2]\t$ratio_5\t$sum[3]\t$num[3]\t$ratio_10\n";
