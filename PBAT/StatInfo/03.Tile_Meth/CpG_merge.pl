#!/usr/bin/perl -w
use strict;

#my @sample = qw/scBS-8C-1-1 scBS-8C-2-1 scBS-8C-6-1 scBS-8C-8-1 scBS-8C-9-1 scBS-ZHB-Sp10 scBS-ZHB-Sp2 scBS-8C-1-2 scBS-8C-2-2 scBS-8C-6-2 scBS-8C-8-2 scBS-8C-9-2 scBS-ZHB-Sp11 scBS-ZHB-Sp3 scBS-8C-1-3 scBS-8C-2-3 scBS-8C-6-3 scBS-8C-8-3 scBS-8C-9-3 scBS-ZHB-Sp12 scBS-ZHB-Sp4 scBS-8C-1-4 scBS-8C-2-4 scBS-8C-6-4 scBS-8C-8-4 scBS-8C-9-4 scBS-ZHB-Sp13 scBS-ZHB-Sp5 scBS-8C-1-5 scBS-8C-2-5 scBS-8C-6-5 scBS-8C-8-5 scBS-8C-9-5 scBS-ZHB-Sp14 scBS-ZHB-Sp6 scBS-8C-1-6 scBS-8C-2-6 scBS-8C-6-6 scBS-8C-8-6 scBS-8C-9-6 scBS-ZHB-Sp15 scBS-ZHB-Sp7 scBS-8C-1-7 scBS-8C-2-7 scBS-8C-6-7 scBS-8C-8-7 scBS-8C-9-7 scBS-ZHB-Sp16 scBS-ZHB-Sp8 scBS-8C-1-8 scBS-8C-2-8 scBS-8C-6-8 scBS-8C-8-8 scBS-8C-9-8 scBS-ZHB-Sp1 scBS-ZHB-Sp9/;
my @sample = @ARGV;
my %hash;
foreach my $sample (@sample){
	#open IN,"/WPSnew/liqingqing/Project/schuman_PGC/1.PBAT/StatInfo_steps/04.TileMet/300bp_CpG/$sample.300bp.C.Tiles" or die $!;
	#open IN,"/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/StatInfo/03.Tile_Meth/100bp_1X/$sample.100bp_1X.txt" or die $!;
	open IN,"/WPSnew/wangrui/Project/Post_Implantation/Human_PBAT/StatInfo/03.Tile_Meth/1000bp_1X/$sample.1000bp_1X.txt" or die $!;
	while(<IN>){
		chomp;
		next if (/^#/);
		my @a = split /\s+/,$_;
		next if ($a[8] < 2);	##300bp tile coer at least 2CpG sites  tile_C_num
		my ($chr, $tileStart, $met) = ($a[0], $a[1], $a[6]);
		$hash{$chr}{$tileStart}{$sample} = $met;
	}
	close IN;
}

#open O,">mergeSampleMet.100bp_2CpG.txt" or die;
open O,">mergeSampleMet.1000bp_2CpG.txt" or die;
print O "Chr\tPos";
foreach my $sample (@sample){
	print O "\t$sample";
}
print O "\n";

foreach my $chr (sort keys %hash){
	foreach my $pos (sort {$a <=> $b} keys %{$hash{$chr}}){
		print O "$chr\t$pos";
		foreach my $sample (@sample){
			if (exists $hash{$chr}{$pos}{$sample}){
				print O "\t$hash{$chr}{$pos}{$sample}";
			}
			else {
				print O "\tNA";	
			}
		}
		print O "\n";
	}
}

