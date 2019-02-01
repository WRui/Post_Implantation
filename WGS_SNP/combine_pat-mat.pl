#!/usr/bin/perl
use utf8;
use warnings;

##############read in paternal sperm data
open IN,"$ARGV[0]" or die $!;
while(<IN>){
	chomp;
	my @a = split /\s+/,$_;
	next if (/CHROM/);
	$sperm_pat{$a[0]}{$a[1]} = "$a[2]\t$a[7]\t$a[8]\t$a[10]";
}
close IN;

print "CHROM\tPOS\tREF\tpat_AD\tpat_GT\tpat_type\tmat_AD\tmat_GT\tmat_type\n";
###############read in maternal oocyte data
open IN,"$ARGV[1]" or die $!;
while(<IN>){
	chomp;
	my @a = split /\s+/,$_;
	next if (/CHROM/);
	if ( $sperm_pat{$a[0]}{$a[1]} ){
		print "$a[0]\t$a[1]\t$sperm_pat{$a[0]}{$a[1]}\t$a[7]\t$a[8]\t$a[10]\n";
	}
}
close IN;


