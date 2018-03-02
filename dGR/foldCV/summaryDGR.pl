#!/usr/bin/perl -w
use strict;

#This script is summarize the result by my method(in GTF fotmat).

my ($in,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <GTF Result by Motif-GHMM> <OUT File>\n" if (@ARGV<2);
open(IN,$in)||die("error with opening $in\n");
open(OUT,">$out")||die("error with writing to $out\n");

print OUT "id\tlength\tscore\tintegrity\tTR\tVR\tRT\n";

my ($id,$len,$score,$integrity,$TR,$VR,$RT)=(0,0,"",0,0,0);
while(<IN>){
    chomp();
    if($_ =~ /TR/){
	$TR++;
	;
    }
    elsif($_ =~ /VR/){
        $VR++;
        ;
    }
    elsif($_ =~ /RT/){
        $RT++;
        ;
    }
    elsif($_ =~ /DGR/){
	my @data = split(/\s+/,$_);
	$len = length($data[6]);
	$score = $data[2];
	$id = $data[0];
	
	if($VR != 0){
	    $integrity = "complete";
	}
	else{
	    $integrity = "incomplete";
	}
	print OUT "$id\t$len\t$score\t$integrity\t$TR\t$VR\t$RT\n";
	($id,$len,$score,$integrity,$TR,$VR,$RT)=("",0,0,"",0,0,0);
    }
    next;
}


close IN;close OUT;
exit;
