#! /usrt/bin/perl
use strict;
use warnings;
## remove forward xbp, backward 0bp
my $usage = "perl $0 <IN1> <OUT> x
<IN1>:fastq.gz
<OUT>:fastq.gz";
#use PerlIO::gzip;
die $usage unless @ARGV==3;
open IN,"gzip -dc $ARGV[0] |" or die $!;
open OUT,"| gzip -c > $ARGV[1]" or die $!;
my $a=0;
while(<IN>)
{
        chomp;
        my $line1=$_;
        chomp(my $line2=<IN>);
        chomp(my $line3=<IN>);
        chomp(my $line4=<IN>);
	my $tso;
	my $polya;
##      if($len_2 >=$ARGV[2]+$ARGV[3])
##      }
		if ($line2 =~m/TGGTATCAACGCAGAGTACAT/g) 
        {
			if ($line2 =~m/AAAAAAAAAAAAAAA/g)
			{	
				$tso = rindex($line2,"TGGTATCAACGCAGAGTACAT");
				$polya = index($line2,"AAAAAAAAAAAAAAA");
				if ($polya - $tso - 21 >= 37)
				{
					my $two=substr($line2,$tso + 21,$polya - $tso - 21);
					my $line4_2=substr($line4,$tso + 21,$polya - $tso - 21);
					print OUT "$line1\n$two\n$line3\n$line4_2\n";
				}
			}
            else
			{	
				$tso = rindex($line2,"TGGTATCAACGCAGAGTACAT");
				if (150 - $tso - 21 >= 37)
				{
					my $two=substr($line2,$tso + 21);
					my $line4_2=substr($line4,$tso + 21);
					print OUT "$line1\n$two\n$line3\n$line4_2\n";
				}
			}
		}
		else
		{
			if ($line2 =~m/AAAAAAAAAAAAAAA/g)
		    {	
		    	$polya = index($line2,"AAAAAAAAAAAAAAA");
		    	if ($polya >= 37)
				{
					my $two=substr($line2,$ARGV[2],$polya);
					my $line4_2=substr($line4,$ARGV[2],$polya);
					print OUT "$line1\n$two\n$line3\n$line4_2\n";
				}	
			}
		    else
		    {	
				my $len_2=length($line2);
		    	my $second=substr($line2,$ARGV[2],$len_2-$ARGV[2]);
		    	my $line4_1=substr($line4,$ARGV[2],$len_2-$ARGV[2]);
		    	print OUT "$line1\n$second\n$line3\n$line4_1\n";
		    }		
		} 
}
close IN;
close OUT;		
		
		
		
		
		
		
		
		
#		{
#				$tso = rindex($line2,"TGGTATCAACGCAGAGTACAT");
#				$polya = index($line2,"AAAAAAAAAAAAAAA");
#				my $two=substr($line2,$tso + 21);
#				my $line4_2=substr($line4,$a);
#                print OUT "$line1\n$two\n$line3\n$line4_2\n";
#		}
#        if ($line2 =~m/TGGTATCAACGCAGAGTACAT/g)
#        {
#                $a = pos($line2);
#                next if (150-$a <= 36);# trim reads >=36bp
#                my $two=substr($line2,$a);
#                my $line4_2=substr($line4,$a);
#                print OUT "$line1\n$two\n$line3\n$line4_2\n";
#        }
##        elsif  ($line2 =~m/TTTTTTTTTTTTTTT/g)
##        {
##                $a = pos($line2);
##                next if ($a < 56);
##                my $two=substr($line2,$ARGV[2],$a-15-$ARGV[2]);
##                my $line4_2=substr($line4,$ARGV[2],$a-15-$ARGV[2]);
##                print OUT "$line1\n$two\n$line3\n$line4_2\n";
##        }
##               # my $len=length($second);
##               # my $third=substr($second,0,$len_2-24);
##               # my $line4_2=substr($line4_1,0,$len_2-24);
##}
#        else
#        {
#                my $len_2=length($line2);
#                my $second=substr($line2,$ARGV[2],$len_2-$ARGV[2]);
#                my $line4_1=substr($line4,$ARGV[2],$len_2-$ARGV[2]);
#                print OUT "$line1\n$second\n$line3\n$line4_1\n";
#        }
#}
#close IN;
#close OUT;
