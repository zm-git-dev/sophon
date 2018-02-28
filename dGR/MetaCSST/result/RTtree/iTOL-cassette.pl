#!/usr/bin/perl -w
use strict;

### iTOL DGR cassette annotation

my ($in,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <IN File> <OUT File>\n" if (@ARGV<2);

open(IN,$in)||die("error\n");
open(OUT,">$out")||die("error\n");

my %group = ();
my %color = ();
$group{"VR+.TR+.RT+"} = "group1";
$group{"VR+.VR+.TR+.RT+"} = "group2";
$group{"VR-.RT-.TR-"} = "group3";
$group{"VR+.VR+.VR+.TR+.RT+"} = "group4";
$group{"VR+.TR+.RT-"} = "group5";
$group{"VR+.RT+.TR+"} = "group6";
$group{"VR+.TR+.RT+.VR+"} = "group7";
$group{"VR+.TR-.RT-"} = "group8";
$group{"VR-.TR+.RT+"} = "group9";

$color{"VR+.TR+.RT+"} = "#EA0000";
$color{"VR+.VR+.TR+.RT+"} = "#5B00AE";
$color{"VR-.RT-.TR-"} = "#019858";
$color{"VR+.VR+.VR+.TR+.RT+"} = "#F9F900";
$color{"VR+.TR+.RT-"} = "#FF5809";
$color{"VR+.RT+.TR+"} = "#B87070";
$color{"VR+.TR+.RT+.VR+"} = "#616130";
$color{"VR+.TR-.RT-"} = "#4F9D9D";
$color{"VR-.TR+.RT+"} = "#E800E8";

while(<IN>){
    chomp();
    my @data = split(/\s+/,$_);
    if(exists($group{$data[1]})){
	print OUT "$data[0] $color{$data[1]} $group{$data[1]}\n";
    }
    else{
	my $reverse = myReverse($data[1]);
	if(exists($group{$reverse})){
	    print OUT "$data[0] $color{$reverse} $group{$reverse}\n";
	}
	else{
	    print OUT "$data[0] #BEBEBE others\n";
	}
    }
}

sub myReverse{
    my ($stru) = @_;
    my @array = split(/\./,$stru);
    my $rev = "";
    for(my $i=@array-1;$i>=0;$i--){
	if($array[$i] =~ /(.+)\+/){
	    $rev .= $1."-.";
	}
	elsif($array[$i] =~ /(.+)\-/){
	    $rev .= $1."+.";
	}
    }
    chop($rev);
    return $rev;
}

close IN;close OUT;
exit;
