#!/usr/bin/perl -w
use strict;

#This scripts is used to get the hit object genes according tot eh VR position and ORFs

my ($vr,$info,$overlap)= @ARGV;
die("usage: $0 <VR.info> <ORF.info> <VR-ORF Overlap info>\n") if (@ARGV<3);

open(INFO,$info)||die("error\n");
open(VR,$vr)||die("error\n");
open(OUT,">$overlap")||die("error\n");

my @VR_INFO = ();
my %pos_index = ();
my $i=0;
my $num = 0;
while(<VR>){
    chomp();
    my @data = split(/\s+/,$_);
    $VR_INFO[$i][0] = $data[0];
    $VR_INFO[$i][1] = $data[1];
    $VR_INFO[$i][2] = $data[2];
    $VR_INFO[$i][3] = $data[3];
    if(not exists($pos_index{$data[0]})){
	$pos_index{$data[0]} = "$i-";
    }
    else{
	$pos_index{$data[0]} .= "$i-";
    }
    $i++;
    $num++;
    next;
}

while(<INFO>){
    chomp();
    my @data = split(/\s+/,$_);
    my ($id,$string,$start,$end) = ($data[0],$data[1],$data[3],$data[4]);
    my $orf_id = $id;
    if($id =~ /(.+)\|ORF/){$id = $1;}
    my @vr_array = split(/-/,$pos_index{$id});
    foreach $i(@vr_array){
	if($id eq $VR_INFO[$i][0]){
	    if($string eq '+'){
		if(!($end<=$VR_INFO[$i][2] || $start>=$VR_INFO[$i][3])){ #overlap
		    print OUT "$VR_INFO[$i][0]\t$VR_INFO[$i][1]\t$VR_INFO[$i][2]\t$VR_INFO[$i][3]\t$orf_id\t$string\t$start\t$end\n";
		}
	    }
	    else{
		if(!($start<=$VR_INFO[$i][2] || $end>=$VR_INFO[$i][3])){ #overlap
		    print OUT "$VR_INFO[$i][0]\t$VR_INFO[$i][1]\t$VR_INFO[$i][2]\t$VR_INFO[$i][3]\t$orf_id\t$string\t$start\t$end\n";
		}
	    }
	}
	else{
	    print "error\n";
	}
    }
}

close INFO;close VR;close OUT;
exit;
