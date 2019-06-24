#!/usr/bin/perl -w 
use strict;

open Child_IN,"$ARGV[0]" or die;
my %hash;
my @line;
my ($Chr,$Pos,$Ref,@Alt,$Info,@Info_Detail,$GT,$Depth,$Type);
my $min_depth = $ARGV[3];

while(<Child_IN>){
	chomp;
	next if($_=~/#/);
	my @line = split(/\s+/,$_);
	my $Chr = $line[0];
	my $Pos = $line[1];
	my $Ref = $line[3];
	my @Alt = split(/,/,$line[4]);
	my $n=@Alt-1;
	#print "$n\t@Alt\n";
	next if (length($Ref)>1||($n>0 && length($Alt[0])>1)||$Ref=~/N/);
	
	my $Info = $line[9];
	my @Info_Detail = split(/:/,$Info);
	my $GT = $Info_Detail[0];
	if($GT=~"0/0"){
		if($n >0) {
			$Depth = $Info_Detail[2];
		}else{
			$Depth = $Info_Detail[1];
		}
		$Type ="$Ref/$Ref";
		#next;

	}elsif($GT=~"0/1"){
		$Depth = $Info_Detail[2];
		my @subdepth = split(/,/,$Info_Detail[1]);
		my $ratio = $subdepth[0]/$Depth;
		next if ($ratio<0.2||$ratio>0.8);
		$Type = "$Ref/$Alt[0]";

	}elsif($GT=~"1/1"){
		$Depth = $Info_Detail[2];
		$Type = "$Alt[0]/$Alt[0]";
		#next;

	}elsif($GT=~"0/2"){
		#next if (length($Alt[0])>1||length($Alt[1])>1);
		#$Depth = $Info_Detail[2];
		#$Type = "$Ref/$Alt[0]|$Alt[1]";
		next;
	}

	next if ($Depth < $min_depth);
	
	$hash{"$Chr\t$Pos\t$Ref"} = "$Depth\t$GT\t$Type";
}

close Child_IN;

open Paternal_IN,"$ARGV[1]" or die $!;

my %Paternal_Hash;
while(<Paternal_IN>){
	chomp;
	next if($_=~/#/);
	my @line = split(/\s+/,$_);
	my $Chr = $line[0];
	my $Pos = $line[1];
	my $Ref = $line[3];
	my @Alt = split(/,/,$line[4]);

	my $n=@Alt-1;
#	print "First Time $Ref\t$Alt[0]\t$n\t@Alt\n";
    next if (length($Ref)>1||($n>0 && length($Alt[0])>1));

    my $Info = $line[9];
    my @Info_Detail = split(/:/,$Info);
    my $GT = $Info_Detail[0];
    if($GT=~"0/0"){
		if($n>0){
			$Depth = $Info_Detail[2];
		}else{
			$Depth = $Info_Detail[1];
		}
        $Type ="$Ref/$Ref";

    }elsif($GT=~"0/1"){
        $Depth = $Info_Detail[2];
        my @subdepth = split(/,/,$Info_Detail[1]);
        my $ratio = $subdepth[0]/$Depth;
        next if ($ratio<0.2||$ratio>0.8);
        $Type = "$Ref/$Alt[0]";

    }elsif($GT=~"1/1"){
        $Depth = $Info_Detail[2];
        $Type = "$Alt[0]/$Alt[0]";

    }elsif($GT=~"0/2"){
        #next if (length($Alt[0])>1||length($Alt[1])>1);
        #$Depth = $Info_Detail[2];
        #$Type = "$Ref/$Alt[0]|$Alt[1]";
        next;
    }
	
#	print "Second Time  $Ref\t$Alt[0]\t$Depth\t$n\t@Alt\n";
    next if ($Depth < $min_depth);

	my $keys = "$Chr\t$Pos\t$Ref";
	if (exists $hash{$keys}) {
		$Paternal_Hash{$keys} = "$Depth\t$GT\t$Type";
	}
}

open Maternal_IN,"$ARGV[2]" or die $!;

my %Maternal_Hash;

while(<Maternal_IN>){
    chomp;
    next if($_=~/#/);
    my @line = split(/\s+/,$_);
    my $Chr = $line[0];
    my $Pos = $line[1];
    my $Ref = $line[3];
    my @Alt = split(/,/,$line[4]);
    my $n=@Alt-1;
    next if (length($Ref)>1||($n>0 && length($Alt[0])>1));

    my $Info = $line[9];
    my @Info_Detail = split(/:/,$Info);
    my $GT = $Info_Detail[0];
    if($GT=~"0/0"){
		if($n>0){
			$Depth = $Info_Detail[2];
		}else{
			$Depth = $Info_Detail[1];
		}
        $Type ="$Ref/$Ref";

    }elsif($GT=~"0/1"){
        $Depth = $Info_Detail[2];
        my @subdepth = split(/,/,$Info_Detail[1]);
        my $ratio = $subdepth[0]/$Depth;
        next if ($ratio<0.2||$ratio>0.8);
        $Type = "$Ref/$Alt[0]";

    }elsif($GT=~"1/1"){
        $Depth = $Info_Detail[2];
        $Type = "$Alt[0]/$Alt[0]";

    }elsif($GT=~"0/2"){
        #next if (length($Alt[0])>1||length($Alt[1])>1);
        #$Depth = $Info_Detail[2];
        #$Type = "$Ref/$Alt[0]|$Alt[1]";
        next;
    }

    next if ($Depth < $min_depth);

	my $keys = "$Chr\t$Pos\t$Ref";
	if (exists $hash{$keys}) {
        $Maternal_Hash{$keys} = "$Depth\t$GT\t$Type";
    }
}

#my $min_depth = $ARGV[3];
open OUT, ">$ARGV[4]" or die $!;

my $pos;
my (@Child_Info,@Paternal_Info,@Maternal_Info);
print OUT "Pos\tChr\tRef\tC_Dep\tC_GT\tP_Dep\tP_GT\tM_Dep\tM_GT\n";

foreach $pos (sort keys %hash) {
#	print "$pos\t$hash{$pos}\n";
	if( exists $Maternal_Hash{$pos} ){
		if (exists $Paternal_Hash{$pos}) {
			@Child_Info = split(/\t/,$hash{$pos});
	        @Paternal_Info = split(/\t/,$Paternal_Hash{$pos});
    	    @Maternal_Info = split(/\t/,$Maternal_Hash{$pos});

			my $Child_GT = $Child_Info[1];
			my $Paternal_GT = $Paternal_Info[1];
			my $Maternal_GT = $Maternal_Info[1];

			my @Child_Type = split(/\//,$Child_Info[2]);
			my @Paternal_Type = split(/\//,$Paternal_Info[2]);
			my @Maternal_Type = split(/\//,$Maternal_Info[2]);
			
			my $Paternal_A = $Paternal_Type[0];
			my $Paternal_B = $Paternal_Type[1];

			my $Maternal_A = $Maternal_Type[0];
			my $Maternal_B = $Maternal_Type[1];

			## Child 0/0 or 1/1
			if($Child_GT =~"0/0" || $Child_GT =~"1/1"){
				my $Child_Allele = $Child_Type[0];
				
				if (($Child_Allele == $Paternal_A || $Child_Allele == $Paternal_B) && ($Child_Allele != $Maternal_A && $Child_Allele != $Maternal_B)){
					my $Phase = "Paternal";
				}elsif(($Child_Allele != $Paternal_A && $Child_Allele != $Paternal_B) && ($Child_Allele == $Maternal_A || $Child_Allele == $Maternal_B)){
					my $Phase = "Maternal";
				}else {
					my $Phase = "Undefined";
				}

			}else{
				my $Child_A = $Child_Type[0];
				my $Child_B = $Child_Type[1];

				my $grep_P_A = length(grep($Child_A,@Paternal_Type));
				my $grep_P_B = length(grep($Child_B,@Paternal_Type));

				my $grep_M_A = length(grep($Child_A,@Maternal_Type));
				my $grep_M_B = length(grep($Child_B,@Maternal_Type));

				if( $grep_P_A ==0 && $grep_P_B !=0 && $grep_M_A !=0 && $grep_M_B == 0){
					my $Phase = "Both";
				}elsif($grep_P_A != 0 && $grep_P_B ==0 && $grep_M_A == 0 && $grep_M_B != 0){
					my $Phase = "Both";
				}else{
					my $Phase = "Undefined";
				}
				
			}
			
			print OUT "$pos\t$hash{$pos}\t$Paternal_Hash{$pos}\t$Maternal_Hash{$pos}\n";

		}
	}
}
