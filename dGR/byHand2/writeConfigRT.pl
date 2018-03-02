#!/usr/bin/perl -w
use strict;

#This script is used to write a new config file according to the argument simulation result

my ($template,$out,$c1_score,$c1_ratio,$c1_len,$c2_score,$c2_ratio,$c2_len,$c3_score,$c3_ratio,$c3_len,$c4_score,$c4_ratio,$c4_len)= @ARGV;
die "Error with arguments!\nusage: $0 <Template Config File> <Out File> <Nine arguments>\n" if (@ARGV!=14);

open(TEM,$template)||die("error with opening $template\n");
open(OUT,">$out")||die("error with writing to $out");

my (@len,@score,@ratio) = ((),(),());
push(@len,$c1_len);push(@len,$c2_len);push(@len,$c3_len);push(@len,$c4_len);
push(@score,$c1_score);push(@score,$c2_score);push(@score,$c3_score);push(@score,$c4_score);
push(@ratio,$c1_ratio);push(@ratio,$c2_ratio);push(@ratio,$c3_ratio);push(@ratio,$c4_ratio);

my $id = -1;
while(<TEM>){
    if($_ =~ /\[motif\]/){
	$id ++;
	print OUT "$_";
    }
    else{
	if($_ =~ /len/){
	    print OUT "len=$len[$id]\n";
	}
	elsif($_ =~ /score/){
	    print OUT "score=$score[$id]\n";
	}
	elsif($_ =~ /ratio/){
            print OUT "ratio=$ratio[$id]\n";
        }
	else{
	    print OUT "$_";
	}
    }
}

close TEM;close OUT;
exit;
