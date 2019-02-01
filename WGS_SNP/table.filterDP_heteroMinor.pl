#!/usr/bin/perl -w
use strict;

open IN,"$ARGV[0]" or die $!;
my $head = <IN>;
print "$head";

while(<IN>){
	chomp;
	my @a = split /\s+/,$_;
	next if (/NA/);
	my $DP = $a[6];
#	next if ($DP < 10);
	next if ($DP < 8);	
#	next if ($DP > 60);
	next if ($DP > 200);	
	if ($a[10] eq "Homo"){
		print join "\t", @a;
		print "\n";
	}
	if ($a[10] eq "Hete"){
		my @AD = sort split /,/,$a[7];  #AD : Allelic depths for the ref and alt alleles in the order listed
		if ( @AD == 2){
			my $rate = $AD[0]/($AD[0]+$AD[1]);
			if ( $rate >= 0.3 && $rate <= 0.7){
				print join "\t", @a;
				print "\n";
			}
		}
	}
}
close IN;

