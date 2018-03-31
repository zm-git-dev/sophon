#!/usr/bin/perl -w
use strict;

#This program is used to get blast hits

my ($file,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <Blast Out files> <OUT file>\n" if (@ARGV<2);

open(OUT,">$out")||die("Can't write to $out\n");
open(FILE,$file)||die("Can't open $file\n");
    
print OUT "Query\tQuery_start\tQuery_end\tHit\tHit_start\tHit_end\tLength\tScore\tEvalue\tIdentities\tGaps\n";
my ($query,$hit,$score,$evalue,$identities,$gaps,$query_start,$query_end,$hit_start,$hit_end,$len) = ("","","","","","",0,0,0,0,0);
while(<FILE>){
    if($_ =~ /[A-Za-z\d]/){
	if($_ =~ /Query=\s([^\s]+)\s/){
	    $query = $1;
	}
	elsif($_ =~ />\s([^\s]+)/){
	    $hit = $1;
	}
	elsif($_ =~ /Query\s+(\d+)\s+[^\s]+\s+(\d+)/){
	    $query_end = $2;
	    if($query_start == 0){
		$query_start = $1;
	    }
	}
	elsif($_ =~ /Sbjct\s+(\d+)\s+[^\s]+\s+(\d+)/){
            $hit_end = $2;
            if($hit_start == 0){
                $hit_start = $1;
            }
        }
	else{
	    if($_ =~ /Score = ([^\s]+) bits/){
		if($score ne ""){
		    $len = abs($hit_end-$hit_start)+1;
		    print OUT "$query\t$query_start\t$query_end\t$hit\t$hit_start\t$hit_end\t$len\t$score\t$evalue\t$identities\t$gaps\n";
		    ($score,$evalue,$identities,$gaps,$query_start,$query_end,$hit_start,$hit_end,$len) = ("","","","",0,0,0,0,0);
		}
		$score = $1;
	    }
	    if($_ =~ /Expect = ([^\s]+)/){
                $evalue = $1;
            }
	    if($_ =~ /Identities = \d+\/\d+ \(([^\s]+)\)/){
                $identities = $1;
            }
	    if($_ =~ /Gaps = \d+\/\d+ \(([^\s]+)\)/){
                $gaps = $1;
            }
	}
    }
    next;
}

if($score ne ""){
    $len = $hit_end-$hit_start+1;
    print OUT "$query\t$query_start\t$query_end\t$hit\t$hit_start\t$hit_end\t$len\t$score\t$evalue\t$identities\t$gaps\n";
}

close FILE;close OUT;
exit;
