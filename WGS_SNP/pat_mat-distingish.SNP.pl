#!/usr/bin/perl -w
use strict;

open IN,"$ARGV[0]" or die $!;

print "CHROM\tPOS\tREF\tpat_allel\tmat_allel\tSNP_type\n";
while(<IN>){
	chomp;
	my @a = split /\s+/,$_;
	next if (/CHROM/);
	if ($a[4] ne $a[7]){
		if ($a[5] eq "Homo" && $a[8] eq "Homo"){
			my @pat = split /\//,$a[4];
			my @mat = split /\//,$a[7];
			print "$a[0]\t$a[1]\t$a[2]\t$pat[1]\t$mat[1]\tDouble\n";
		}
		if ($a[5] eq "Hete" && $a[8] eq "Hete"){
			my @pat = split /\//,$a[4];
			my @mat = split /\//,$a[7];
			print "$a[0]\t$a[1]\t$a[2]\t$pat[1]\t$mat[1]\tDouble\n";
		}
		if ($a[5] eq "Hete" && $a[8] eq "Homo"){  ##ref : C ;pat:C/T; mat:T/T
			my @pat = split /\//,$a[4];
			my @mat = split /\//,$a[7];
##ref: T ;  pat:T/A;  mat:G/G
			if ( $pat[1] ne $mat[0] ){
				print "$a[0]\t$a[1]\t$a[2]\t$pat[0]\t$mat[0]\tDouble\n";
				print "$a[0]\t$a[1]\t$a[2]\t$pat[1]\t$mat[0]\tDouble_1\n";
			}
			if ( $pat[1] eq $mat[0] ){
				print "$a[0]\t$a[1]\t$a[2]\t$pat[0]\t$mat[0]\tonly_tace_pat\n";
			}
		}
		if ($a[5] eq "Homo" && $a[8] eq "Hete"){ ##ref:c ; pat:T/T; mat:C/T
			my @pat = split /\//,$a[4];
			my @mat = split /\//,$a[7];
			if ( $pat[1] ne $mat[1] ){
				print "$a[0]\t$a[1]\t$a[2]\t$pat[1]\t$mat[0]\tDouble\n";
				print "$a[0]\t$a[1]\t$a[2]\t$pat[1]\t$mat[1]\tDouble_1\n";
			}
			if ( $pat[1] eq $mat[1] ){
				print "$a[0]\t$a[1]\t$a[2]\t$pat[1]\t$mat[0]\tonly_tace_mat\n";
			}
		}
	}
}
close IN;
