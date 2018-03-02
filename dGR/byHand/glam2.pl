#!/usr/bin/perl -w
use strict;

my ($file,$out,$motif)= @ARGV;
die "Error with arguments!\nusage: $0 <Fasta File to call motif> <OUT file> <Motif OUT directory>\n" if (@ARGV<3);
system("glam2 n $file -O $motif");
#system("glam2 -Q -O $motif -M -2 -z 2 -a 2 -b 50 -w 20 -r 10 -n 2000 -D 0.1 -E 2.0 -I 0.02 -J 1.0 n $file");
system("sh eps2png.sh $motif");

my $in="$motif/glam2.txt";
open(IN,$in)||die("Can't open $in\n");
open(OUT,">$out")||die("Can't write to $out\n");

my $index = 0;
while(<IN>){
    chomp();
    if($index == 0){
	if($_ =~ /\*/){
	    $index = 1;
	}
    }
    else{
	if($_ =~ /\d+\s+([atcg\.]+)\s+\d+/){
	    my $line = upper($1);
	    print OUT "$line\n"
	}
	else{
	    last;
	}
    }
    next;
}

sub upper{
    my ($input) = @_;
    my $output = "";
    for(my $i=0;$i<length($input);$i++){
	my $sub=substr($input,$i,1);
	if($sub eq "a"){
	    $output .= "A";
	}
	elsif($sub eq "t"){
            $output .= "T";
	}
	elsif($sub eq "c"){
            $output .= "C";
        }
	elsif($sub eq "g"){
            $output .= "G";
        }
	else{
	    $output .= $sub;
	}
    }
    return $output;
}


close IN;close OUT;
exit;
