#!/usr/bin/perl -w
use strict;
use warnings;
my $file=$ARGV[0];
open OUT,">$ARGV[1]" or die $!;

print OUT "Sample\tnonCGs(1X)\tTotalUnique(1X)\tMeanCov(1X)\tMethRatio(1X)\tMethReadRatio(1X)\tnonCGs(3X)\tTotalUnique(3X)\tMeanCov(3X)\tMethRatio(3X)\tMethReadRatio(3X)\tnonCGs(5X)\tTotalUnique(5X)\tMeanCov(5X)\tMethRatio(5X)\tMethReadRatio(5X)\tnonCGs(10X)\tTotalUnique(10X)\tMeanCov(10X)\tMethRatio(10X)\tMethReadRatio(10X)\n";


my @depth=(1,3,5,10);
my $length=@depth;
my (@sum,@num,$name,@meth,@meth_ratio);
my $j;
$name=$ARGV[2];

#$num[0]=$num[1]=$num[2]=$num[3]=0;
#open(FH,"gzip -dc $file |") or die "fail open the file";
open(FH, $file) or die "fail open the file";
while(<FH>){
	chomp;
	my $line=$_;
	next if ($line =~/#/);
	next if ($line =~/lambda/);
#	print "$line\n";
	my @words=split(/\s+/,$line);
	for($j=0;$j<$length;$j++){
		if($words[4]>=$depth[$j] && $words[9]=~/CH[HG]/){
			#print "@words\n";
			$sum[$j]+=$words[4];
			#print "total\t$words[4]\t";
			$num[$j]++;
			$meth[$j]+=$words[5];
			#print "meth\t$words[5]\t";
			$meth_ratio[$j]+=$words[7];
			#print "methRatio\t$words[7]\n";
		}
	}
}


my $ratio_1 = $sum[0]/$num[0];
my $Meth_Ratio_1 = $meth_ratio[0]/$num[0];
my $Meth_Read_1 = $meth[0]/$sum[0];

my ($ratio_3,$Meth_Ratio_3,$Meth_Read_3);

if($num[1]==0){
	$sum[1] = $ratio_3 = $Meth_Ratio_3 = $Meth_Read_3 = 0 ;
}else {
	$ratio_3 = $sum[1]/$num[1];
	$Meth_Ratio_3 = $meth_ratio[1]/$num[1];
	$Meth_Read_3 = $meth[1]/$sum[1];
}
#my $ratio_3 = $sum[1]/$num[1];
#my $Meth_Ratio_3 = $meth_ratio[1]/$num[1];
#my $Meth_Read_3 = $meth[1]/$num[1];

my ($ratio_5,$Meth_Ratio_5,$Meth_Read_5);
if($num[2]==0){
	$sum[2] = $ratio_5 = $Meth_Ratio_5 = $Meth_Read_5 =0;
}else{
	$ratio_5 =  $sum[2]/$num[2];
	$Meth_Ratio_5 = $meth_ratio[2]/$num[2];
	$Meth_Read_5 = $meth[2]/$sum[2];
}

#my $ratio_5 =  $sum[2]/$num[2];
#my $Meth_Ratio_5 = $meth_ratio[2]/$num[2];
#my $Meth_Read_5 = $meth[2]/$num[2];

my ($ratio_10, $Meth_Ratio_10, $Meth_Read_10);
if($num[3]==0){
	$sum[3] = $ratio_10 = $Meth_Ratio_10 = $Meth_Read_10 = 0;
}else{
	$ratio_10 = $sum[3]/$num[3];	
	$Meth_Ratio_10 = $meth_ratio[3]/$num[3];
	$Meth_Read_10 = $meth[3]/$sum[3];
}
#my $ratio_10 = $sum[3]/$num[3];
#my $Meth_Ratio_10 = $meth_ratio[3]/$num[3];
#my $Meth_Read_10 = $meth[3]/$num[3];

print OUT "$name\t$sum[0]\t$num[0]\t$ratio_1\t$Meth_Ratio_1\t$Meth_Read_1\t$sum[1]\t$num[1]\t$ratio_3\t$Meth_Ratio_3\t$Meth_Read_3\t$sum[2]\t$num[2]\t$ratio_5\t$Meth_Ratio_5\t$Meth_Read_5\t$sum[3]\t$num[3]\t$ratio_10\t$Meth_Ratio_10\t$Meth_Read_10\n";
