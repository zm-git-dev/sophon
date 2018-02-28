#!/usr/bin/perl -w
use strict;

my ($in,$out)= @ARGV;

die "Error with arguments!\nusage: $0 <In GTF File> <OUT GTF File>\n" if (@ARGV<2);
open(IN,$in)||die("error\n");
open(OUT,">$out")||die("error\n");

my $TR= "";
my %hash = ();
while(<IN>){
    chomp();
    my @arr = split(/\s+/,$_);
    if($arr[1] eq "TR"){$TR = $_;}
    elsif($arr[1] eq "VR"){
	my @data_TR = split(/\s+/,$TR);
	my @data_VR = split(/\s+/,$_);
	
	my $key = $data_TR[0].$data_TR[1].$data_TR[2].$data_TR[5].$data_TR[6].$data_VR[1].$data_VR[2].$data_VR[5].$data_VR[6];
	if(not exists($hash{$key})){
	    print OUT "$TR\n$_\n";
	    $hash{$key} = 1;
	}
    }
    else{
	print OUT "$_\n";
    }
}

close IN;close OUT;
exit;
