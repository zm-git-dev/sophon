#!/usr/bin/perl -w
use strict;

open(FILE,"pair.txt")||die("error\n");
my ($TR,$VR) = ("","");
while(<FILE>){
    chomp();
    my @arr = split(/\s+/,$_);
    if($_ =~ /TR/){
	$TR = $arr[1];
    }
    else{
	$VR = $arr[1];
	my $num = 0;
	if(length($TR) == length($VR)){
	    for(my $i=0;$i<length($TR);$i++){
		my $char1 = substr($TR,$i,1);
		my $char2 = substr($VR,$i,1);
		if($char1 eq 'A' && $char2 ne 'A'){
		    $num ++;
		}
	    }
	    print "$num\n";
	}
    }
}

exit;
