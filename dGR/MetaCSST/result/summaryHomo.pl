#!/usr/bin/perl -w
use strict;

my ($gtf)= @ARGV;

die "Error with arguments!\nusage: $0 <GTF File>\n" if (@ARGV<1);
open(GTF,$gtf)||die("error\n");

my ($id,$tmp,$TR) = ("","","");
while(<GTF>){
    chomp();
    my @arr = split(/\s+/,$_);
    if($arr[1] eq "TR"){$TR = $_;}
    elsif($arr[1] eq "VR"){
	my @data_TR = split(/\s+/,$TR);
	if(my $homo = reCheck($data_TR[9],$arr[9])){
	    my $len = length($arr[9]);
	    print "$arr[0]\t$data_TR[5]\t$data_TR[6]\t$arr[5]\t$arr[6]\t$arr[7]\t$arr[8]\t$data_TR[9]\t$arr[9]\t$homo\t$len\n";
	}
    }
}

sub reCheck{
    my ($TR,$VR) = @_;
    my $same = 0;
    for(my $i=0;$i<length($TR);$i++){
	my $char1 = substr($TR,$i,1);
	my $char2 = substr($VR,$i,1);
	if($char1 eq $char2){
	    $same ++;
	}
    }
    my $homo_this = sprintf("%0.2f",$same/length($TR));
    return $homo_this;
}

exit;
