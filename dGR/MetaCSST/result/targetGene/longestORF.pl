#!/usr/bin/perl -w
use strict;

#This scripts is used to get the longest ORFs to represent the genes, only the longer ORF is retained if two ORFs are overlapped

my ($orf,$out)= @ARGV;
die("usage: $0 <ORF.info> <OUT File>\n") if (@ARGV<2);

open(IN,$orf)||die("error\n");
open(OUT,">$out")||die("error\n");

my @data = ();
my $num = 0;
my $id = "";
my $strain = "";
my @index = ();
while(<IN>){
    my @arr = split(/\s+/,$_);
    if($strain eq ""){
	for(my $i=0;$i<=4;$i++){
	    $data[$num][$i] = $arr[$i];
	}
	$index[$num] = 0;
	$id = $arr[0];
	$num += 1;
	$strain = $arr[1];
    }
    else{
	if($arr[0] ne $id){
	    for(my $i=0;$i<$num;$i++){
                for(my $j=0;$j<=4;$i++){
                    print OUT "$data[$i][$j]\t";
                }
                print OUT "\n";
            }
            @data = ();
            $num = 0;
            @index = ();
	    $id = $arr[0];
	    for(my $i=0;$i<=4;$i++){
                $data[$num][$i] = $arr[$i];
            }
            $index[$num] = 0;
            $num += 1;
            $strain = $arr[1];
	}
	elsif($arr[1] ne $strain){
	    for(my $i=0;$i<$num;$i++){
		for(my $j=0;$j<=4;$i++){
		    print OUT "$data[$i][$j]\t";
		}
		print OUT "\n";
	    }
	    @data = ();
	    $num = 0;
	    @index = ();
	    for(my $i=0;$i<=4;$i++){
		$data[$num][$i] = $arr[$i];
	    }
	    $index[$num] = 0;
	    $num += 1;
	    $strain = $arr[1];
	}
	elsif($arr[2] == 1){
	    for(my $i=0;$i<=4;$i++){
                $data[$num][$i] = $arr[$i];
            }
	    $index[$num] = 0;
            $num += 1;
	}
	else{
	    if($strain eq "+"){
		my $len = $arr[4]-$arr[3];
		for(my $i=0;$i<$num;$i++){
		    if(!($arr[4]<$data[$num][3] && $arr[3]>$data[$num][4])){
			my $len_this = $data[$num][4] - $data[$num][3];
			if($len > $len_this){
			    
			}
		    }
		}
	    }
	}
    }
    next;
}

for(my $i=0;$i<$num;$i++){
    for(my $j=0;$j<=4;$i++){
	print OUT "$data[$i][$j]\t";
    }
    print OUT "\n";
}

close IN;close OUT;
exit;
