#!/usr/bin/perl 
# Written by Rui Wang 2017/0715
# Some Code were learn from former RNA_UMI pipeline which  were written by  Zhuping,Huboqiang, Liuxiaomeng, Lilin ,Dongji .....
# Thank you ~ ^-^
use strict;
use warnings;
#use Switch;

if(@ARGV!=4) {
	print "This Script is used to (01-split barcode) (02-add UMI) (03-Trim TSO)\n";
	print "Usage : perl $0 fq1 fq2 Barcode-Sample-Pair outpath\n";
	print "The format of Barcode-Sample-Pair file is:\nB1-Seq\tSampe1\nB2-Seq\tSample2\n...\t...\n";
}

my $polyA   = 'A'x15;
my $min_len = 40;
my $quality = 33;
my $N_rate = 0.1;
my $Qmin = ($quality + 5);
my $Qrate = 0.5;


my ($Q20_1,$Q30_1) = (0) x 2;
my ($Q20,$Q30);

($quality == 64) ? (($Q20,$Q30) = (84,94)) : (($Q20,$Q30) = (53,63));

my (%hash_base,%hash_quality,%hash_count);


## Define sub function

#function to get cell-Barcode and UMI sequence from Read2
sub grep_Barcode_UMI {
	my ($seq) = @_;
	my $UMI = substr($seq,8,8) ;
	my $Barcode = substr($seq,0,8);
	return ($Barcode,$UMI);
}


#function to trim TSO and polyA
my $TSO_seq	= "TGGTATCAACGCAGAGTACAT";

## 
my @adapter = ("AGATCGGAAGAGC","GCTCTTCCGATCT");

#my $PolyA_seq = "AAAAAAAAAAAAAAA"; ## poly A can be trim in the QC step
sub trim_TSO{
	my ($seq,$quality) = @_;
	my $tso;
	my $trim_seq;
	my $trim_qua;
#	my $TSO_seq = "TGGTATCAACGCAGAGTACAT";
#	my $PolyA_seq = "AAAAAAAAAAAAAAA";
	if($seq =~m/$TSO_seq/g){
		$tso = rindex($seq,$TSO_seq);
		$trim_seq = substr($seq,$tso+21);
		$trim_qua = substr($quality,$tso+21);
		return($trim_seq,$trim_qua);
	}else{
		return($seq,$quality);
	}
}


# function to QC the Read1

#-remove adapter
sub remove_adapter {
    my ($seq,$n) = @_;
    my $adapt = \@adapter;
    $n--;
    while ($seq =~/$$adapt[$n]/g){
        my $pos = pos($seq) - length($$adapt[$n]) + 1;
        return $pos;
    }
    return 0 ;
}

#-count the quality at each site && count the low quality
sub count_quality {
    my($seq,$Q_20,$Q_30,$start_site) = @_;
    my($i,$low_q_site,$base_quality) = (0) x 3;
    my $length = length($seq);
    while ($i < $length) {
        my $base_asc = substr($seq,$i,1);
        $base_quality = ord($base_asc);
        $hash_quality{$i+$start_site} += $base_quality;
        $hash_count{$i+$start_site} ++;
        $low_q_site++ if ($base_quality <= $Qmin);
        $$Q_20++ if ($base_quality >= $Q20);
            $$Q_30++ if ($base_quality >= $Q30);
        $i++;
    }
    ($low_q_site >= $length*$Qrate) ? (return 1) : (return 0);
}

#-count bases at each site
sub count_bases {
    my ($seq,$start_site) = @_;
    my $length = length($seq);
    my $i = 0;
    while ($i < $length) {
        my $base = substr($seq,$i,1);
        $hash_base{$i+$start_site}{$base}++;
        $i++;
    }
    my $N_num = ($seq =~ tr/N/N/) + 0;
    (return 1) if ($N_num >= $length * $N_rate);
    return 0;
}




open IN_1,"gzip -dc $ARGV[0] |" or die $!;
open IN_2,"gzip -dc $ARGV[1] |" or die $!;
open SP,"$ARGV[2]" or die $!;
my $outdir = "$ARGV[3]";

print "Begin at : ".`date +%Y-%m-%d,%H:%M:%S`;

my %SampleList;
while(<SP>){
	chomp;
	my @line = split(/\s+/,$_);
#	print $line[1]\t$line[2] ;
	$SampleList{$line[0]} = $line[1]; ## the hash key is the barcode sequence , the hash value is the samplename
#	print "$line[0]\t$line[1]\n";
}

my %reads_out;
my $key;
foreach $key (sort keys %SampleList){
	my $sample = $SampleList{"$key"};
	print $key."\t" . $SampleList{$key}."\n";
	`mkdir -p $outdir/$sample` unless(-d "$outdir/$sample");
	open $reads_out{$key} ,  "| gzip -c > $outdir/$sample/$sample.R1.clean.fq.gz" or die $!;
	close $reads_out{$key} ;
	#print $reads_out{$key}."\n";
	#open $SampleList{$key} , ">" , ($outdir . "/" .$sample. "_R1.clean_fq.gz") or die;
	#print "$sample\t".$outdir."/",$sample."_R1.clean.fq.gz";
}

my ($unidentified,$identified,%iden_BC);
my (%read,%read_num);
my $Seq_num;
my ($barcode,$UMI);

#while(<IN_1>) {
while(1){
	my $line1_1 = <IN_1>;
	my $line1_2 = <IN_1>;
	my $line1_3 = <IN_1>;
	my $line1_4 = <IN_1>;

	my $line2_1 = <IN_2>;
	my $line2_2 = <IN_2>;
	my $line2_3 = <IN_2>;
	my $line2_4 = <IN_2>;

	#last unless (defined($line1_1) and defined($line2_1));
	
	unless (defined($line1_1) and defined($line2_1)) {
		foreach my $key (sort keys %read_num){
			my $tmp_num = $read_num{$key};
			my $j;
			my $sample = $SampleList{"$key"};
			open $reads_out{$key} ,  "| gzip -c >> $outdir/$sample/$sample.R1.clean.fq.gz" or die $!;
			for ($j=1;$j <= $tmp_num;$j++){
			
				print { $reads_out{($key)} } "$read{$key}{$j}";
			
			}
			close $reads_out{$key};
		}
		
		last;
	}
	chomp ($line1_1,$line1_2,$line1_3,$line1_4,$line2_1,$line2_2,$line2_3,$line2_4);

	#if($ik==0){
	$Seq_num++;
	#if($read{name} ne $reap{name}) { print STDERR "Warning: inconsistence read name [$Seq_num] $read{name} $reap{name}\n"; }
	($barcode,$UMI) = &grep_Barcode_UMI($line2_2); ## get barcode and UMI Info from read2
			my ($read1_name,$seq_left,$qua_left);
			if(exists $SampleList{$barcode}){
					
				#print "$barcode $UMI\n";

				$read1_name = "@".$UMI."_".$line1_1;
				($seq_left,$qua_left) = &trim_TSO($line1_2,$line1_4);
				$iden_BC{$barcode}++;
				$identified++;
				
				## Remove Sequence adapter
				my $remove_adapter = remove_adapter($seq_left,1);
				if ($remove_adapter>0 && $remove_adapter < 37){
					next;
				}elsif($remove_adapter != 0){
					$seq_left = substr($seq_left,0,($remove_adapter -1));
					$qua_left = substr($qua_left,0,($remove_adapter -1));
				}


				## Remove PolyA
				my $polyA_r1 = index $seq_left ,$polyA;
				if($polyA_r1 != -1) {
					$seq_left = substr($seq_left,0,$polyA_r1);
					$qua_left = substr($qua_left,0,$polyA_r1);
				}

				# Remove Short Reads
				my $r1_seqlen = length $seq_left;
				next if ($r1_seqlen < $min_len);
				
				#-count bases at each site && count N content higher than %10
				my $remove_n1 = count_bases($seq_left,0);

				#-count the quality at each site && count the low quality
				my $low1 = count_quality($qua_left,\$Q20_1,\$Q30_1,0);

                #-remove N content higher than %10
				if ($remove_n1){
                    next;
                }

                #-remove the low quality
                if ($low1) {
                    next;
                }
				
				$read_num{$barcode}++;
	            my $num = $read_num{$barcode};                                        
				$read{$barcode}{$num}="$read1_name\n$seq_left\n$line1_3\n$qua_left\n";
				
				if($num == 10000){
					my $sample = $SampleList{"$barcode"};
					#print $sample;
					open $reads_out{$barcode} ,  "| gzip -c >> $outdir/$sample/$sample.R1.clean.fq.gz" or die $!;
					for (my $i=1;$i <= $num;$i++){
	
			            print { $reads_out{($barcode)} } "$read{$barcode}{$i}";

					}
					close $reads_out{$barcode};
					$read_num{$barcode} = 0 ;
				}
				
				
			}else{
				$unidentified++;
			}
			
}

## after all reads were processed
print "Total Read1       : $Seq_num\n" ;
print "Indentified Read2 : $identified\n" ;
print "Undedtified Read2 : $unidentified\n";
print (("-" x 30) . "\n");

my $value;
foreach $key (sort keys %SampleList){
	$value = $SampleList{$key};
	print "$key\t$value\t$iden_BC{$key}\n";
}
print "End at : ".`date +%Y-%m-%d,%H:%M:%S`;
print (("-" x 30) . "\n");

