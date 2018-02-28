#!/usr/bin/perl -w
use strict;

#This scripts is used to get the unique VRs, and the overlapped VRs will be merged and only retain one copy

my ($vr,$out)= @ARGV;
die("usage: $0 <VR.info> <OUT File>\n") if (@ARGV<2);

open(VR,$vr)||die("error\n");
open(OUT,">$out")||die("error\n");

my @array = ();
my $num = 0;
my $id = "";

while(<VR>){
    chomp();
    my @data = split(/\s+/,$_);
    if($data[0] ne $id){
	if($num!=0){
	    for(my $i=0;$i<$num;$i++){
		print OUT "$array[$i][0]\t$array[$i][1]\t$array[$i][2]\t$array[$i][3]\n";
	    }
	}
	@array = ();$num = 0;$id = $data[0];
	for(my $i=0;$i<=3;$i++){
	    $array[$num][$i] = $data[$i];
	}
	$num++;
    }
    else{
	if($data[2] > $array[$num-1][3]){
	    for(my $i=0;$i<=3;$i++){
		$array[$num][$i] = $data[$i];
	    }
	    $num ++;
	}
	else{
	    if($data[3] > $array[$num-1][3]){
		$array[$num-1][3] = $data[3];
	    }
	}
    }
    next;
}

for(my $i=0;$i<$num;$i++){
                print OUT "$array[$i][0]\t$array[$i][1]\t$array[$i][2]\t$array[$i][3]\n";
}

close VR;close OUT;
exit;
