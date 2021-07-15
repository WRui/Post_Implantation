#!/usr/bin/perl -w
use strict;


# Two parameters should be assigned
# 1) Input bam file
# 2) Output bam file name
open IN,"/date/lilin/software/samtools-0.1.18/samtools view -hX $ARGV[0] | " or die $!;
open OUT,"| /date/lilin/software/samtools-0.1.18/samtools view -Sb - > $ARGV[1]" or die $!;
while(<IN>){
	chomp;
	if (/^@/){
		print OUT "$_\n";
		next;
	}
	my @a = split /\t/,$_;
	if ($a[0] =~ m/\/\d$/){
       my @ff = split( /\//, $a[0] );
       $a[0] = $ff[0];
    }
	my $line = join ("\t",@a);
	print OUT "$line\n";
}
close IN;
close OUT;
