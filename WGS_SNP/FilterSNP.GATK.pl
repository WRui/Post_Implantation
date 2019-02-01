#!/usr/bin/perl -w
use strict;

open IN,"$ARGV[0]" or die $!;
my $head = <IN>;
chomp $head;
print "$head\tHomo/Hete\n";

while(<IN>){
    chomp;
    my @a = split /\s+/,$_;
    my $dbsnp = $a[3];
    my $filter = $a[5];
    next if ($dbsnp eq "." or $filter ne "PASS");
    my @gt = sort split /\//,$a[8];
    my $type = "Hete";
    if ($gt[0] eq $gt[1]){
        $type = "Homo";
    }
    print join "\t", @a;
    print "\t$type\n";
}
close IN;
    
