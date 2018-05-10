#!/usr/bin/perl -w
use strict;

## calculate the A,T,C,G percentage of the genome

my ($genome)= @ARGV;
die "Error with arguments!\nusage: $0 <Genome.fa>\n" if (@ARGV<1);

if($genome =~ /\.gz/){
    open(GENOME,"gzip -dc $genome|")||die("error");
}
else{
    open(GENOME,$genome)||die("error\n");
}

my ($A,$T,$C,$G) = (0,0,0,0);
while(<GENOME>){
    chomp();
    if($_ !~ />/){
	my $seq = $_;
	my $len = length($seq);
	for(my $i=0;$i<$len;$i++){
	    my $base = substr($seq,$i,1);
	    if($base eq 'A' || $base eq 'a'){
		$A += 1;
	    }
	    elsif($base eq 'T' || $base eq 't'){
                $T += 1;
            }
	    elsif($base eq 'C' || $base eq 'c'){
                $C += 1;
            }
	    elsif($base eq 'G' || $base eq 'g'){
                $G += 1;
            }
	}
    }
}

my $sum = $A+$T+$C+$G;
$A = sprintf("%0.4f",$A/$sum);
$T = sprintf("%0.4f",$T/$sum);
$C = sprintf("%0.4f",$C/$sum);
$G = sprintf("%0.4f",$G/$sum);
print "$genome\t$A\t$T\t$C\t$G\n";

close GENOME;
exit;
