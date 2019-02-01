#!/usr/bin/perl -w
use strict;

open SNP,"$ARGV[0]" or die $!;
open AUTOSOME,">$ARGV[1]" or die $!;
open CHRX, ">$ARGV[2]" or die $!;

my $sample = $ARGV[3];
<SNP>;
my $P_Ratio;
print AUTOSOME "Chr\tstart\tPos\tRef\tSample\tC_Dep\tC_GT\tC_Type\tC_AD\tP_Dep\tP_GT\tP_Type\tM_Dep\tM_GT\tM_Type\tPhased\tP_Ratio\n";
print CHRX "Chr\tstart\tPos\tRef\tSample\tC_Dep\tC_GT\tC_Type\tC_AD\tP_Dep\tP_GT\tP_Type\tM_Dep\tM_GT\tM_Type\tPhased\tP_Ratio\n";

#<SNP>; # The Header
my ($Chr,$Pos,$Ref,$C_Dep,$C_GT,$C_Type,$C_AD,$P_Dep,$P_GT,$P_Type,$M_Dep,$M_GT,$M_Type);
while(<SNP>){
	chomp;
#	my $line = $_;
	($Chr,$Pos,$Ref,$C_Dep,$C_GT,$C_Type,$C_AD,$P_Dep,$P_GT,$P_Type,$M_Dep,$M_GT,$M_Type) = split(/\s+/,$_);
	my $start = $Pos-1 ;
	my $line = "$Chr\t$start\t$Pos\t$Ref\t$sample\t$C_Dep\t$C_GT\t$C_Type\t$C_AD\t$P_Dep\t$P_GT\t$P_Type\t$M_Dep\t$M_GT\t$M_Type";
	
	#print "$C_Dep\t$C_AD\n";
	next if ($C_GT=~"0/0" && $P_GT=~"0/0" && $M_GT=~"0/0");
	next if ($P_Type eq $M_Type);
	if ($Chr =~"X"){
		if($C_GT=~"0/0" || $C_GT =~ "1/1"){
			my @tmp = split(/\//,$C_Type);
			my $Child = $tmp[0];
			if($P_Type =~$Child && not($M_Type =~$Child)){
				print CHRX "$line\tP_mono\t1\n"; ## 1 represent the ratio of reads from paternal
			}elsif(not($P_Type =~$Child) && $M_Type =~$Child ){
				print CHRX "$line\tM_mono\t0\n";  ## 0 represent the ratio of reads from paternal
			}
			
		}elsif($C_GT =~ "0/1"){ 
			my ($Child_A,$Child_B) = split(/\//,$C_Type);
			my @tmp_AD = split(/,/,$C_AD);
			my $A_Depth = $tmp_AD[0];
			my $B_Depth = $tmp_AD[1];

			if ($P_GT =~ "0/0" || $P_GT =~ "1/1"){
				if($P_Type =~ $Child_A && $M_Type =~ $Child_B){
					$P_Ratio = $A_Depth/$C_Dep;
					print CHRX "$line\tBiallelic\t$P_Ratio\n";
				}elsif($P_Type =~ $Child_B && $M_Type =~ $Child_A){
					$P_Ratio = $B_Depth/$C_Dep;
					print CHRX "$line\tBiallelic\t$P_Ratio\n";
				}
			}elsif($P_GT =~ "0/1"){
				next if ($M_GT =~ "0/1");
				if($P_Type =~ $Child_A && $M_Type =~ $Child_B){
					$P_Ratio = $A_Depth/$C_Dep;					
                    print CHRX "$line\tBiallelic\t$P_Ratio\n";
                }elsif($P_Type =~ $Child_B && $M_Type =~ $Child_A){
				 	$P_Ratio = $B_Depth/$C_Dep;
					print CHRX "$line\tBiallelic\t$P_Ratio\n";
				}
			}
		}
	}else{ ## Mapping to other chromosome 1-22 && chrY
		next if ($P_GT=~"0/1" && $M_GT=~"0/1"); ## Child heterozygous and at least on parent homozygous can phased.
		next unless ($C_GT=~"0/1");
		
		my ($Child_A,$Child_B) = split(/\//,$C_Type);
		#my ($A_Depth,$B_Depth) = split(/,/,$C_AD)[0:1];
		my @tmp_AD = split(/,/,$C_AD);
		my $A_Depth = $tmp_AD[0];
		my $B_Depth = $tmp_AD[1];

		if ($P_GT =~ "0/0" || $P_GT =~ "1/1"){ ## Paternal homozygous 
			if($P_Type =~ $Child_A && $M_Type =~ $Child_B){
				$P_Ratio = $A_Depth/$C_Dep;
				print AUTOSOME "$line\tPhased\t$P_Ratio\n";	
			}elsif($P_Type =~ $Child_B && $M_Type =~ $Child_A){
				$P_Ratio = $B_Depth/$C_Dep;
				print AUTOSOME "$line\tPhased\t$P_Ratio\n";
			}
		}else{
			next if ($M_GT =~ "0/1");
	
			if($P_Type =~ $Child_A && $M_Type =~ $Child_B){
				$P_Ratio = $A_Depth/$C_Dep;
				print AUTOSOME "$line\tPhased\t$P_Ratio\n";
			}elsif($P_Type =~ $Child_B && $M_Type =~ $Child_A){
				$P_Ratio = $B_Depth/$C_Dep;
				print AUTOSOME "$line\tPhased\t$P_Ratio\n";
			}
		}
		
	}
	
}
