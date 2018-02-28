#!/usr/bin/perl -w
use strict;

my ($tr,$vr) = @ARGV;
die "Error with arguments!\nusage: $0 <TR.txt> <VR.txt>\n" if (@ARGV<2);

open(TR,$tr)||die("error\n");
open(VR,$vr)||die("error\n");

my @seqTR = ();
my @seqVR = ();

while(<TR>){
    chomp;
    if($_ !~ />/){
	push(@seqTR,$_);
    }
    next;
}

while(<VR>){
    chomp;
    if($_ !~ />/){
        push(@seqVR,$_);
    }
    next;
}

my @mut=();
for(my $i=0;$i<4;$i++){
    for(my $j=0;$j<4;$j++){
	$mut[$i][$j] = 0;
    }
}

my ($m,$n) = (0,0);
for(my $i=0;$i<@seqTR;$i++){
    my ($seq1,$seq2) = ($seqTR[$i],$seqVR[$i]);
    if(length($seq1) == length($seq2)){
	for(my $j=0;$j<length($seq1);$j++){
	    my $char1 = substr($seq1,$j,1);
	    my $char2 = substr($seq2,$j,1);
	    if($char1 ne $char2){
		if($char1 eq 'A'){
		    $m = 0;
		}
		elsif($char1 eq 'T'){
                    $m = 1;
		}
		elsif($char1 eq 'C'){
                    $m = 2;
                }
		elsif($char1 eq 'G'){
                    $m = 3;
                }
		else{
		    $m = -1;
		}
		
		if($char2 eq 'A'){
                    $n = 0;
                }
		elsif($char2 eq 'T'){
                    $n = 1;
                }
                elsif($char2 eq 'C'){
                    $n = 2;
                }
                elsif($char2 eq 'G'){
                    $n = 3;
                }
		else{
		    $n = -1;
		}
		
		if($m != -1 && $n != -1){
		    $mut[$m][$n] += 1;
		}
	    }
	}
    }
}

for(my $i=0;$i<4;$i++){
    for(my $j=0;$j<4;$j++){
	print "$mut[$i][$j]\t";
    }
    print "\n";
}


close TR;close VR;
exit;
