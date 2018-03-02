#!/usr/bin/perl -w
use strict;

###This sctipt is used to summarize the differential expression information based on the Cuffdiff output of the tumor samples, with the expression value compared to the corresponding normal samples

my ($out,$id,@diff)= @ARGV;
die "Error with arguments!\nusage: $0 <OUT FILE> <gene.id/transcript.id> <differential expression files by Cuffdiff>\n" if (@ARGV<3);
open(OUT,">$out")||die("error\n"); #OUT FILE

my $qvalue = 0.05;

my @data = (); #main data array, contains all the needed information
for(my $i=0;$i<=600000;$i++){
    for(my $j=0;$j<=100;$j++){
	$data[$i][$j] = "."; #inilization, nothing
    }
}

my %index = (); #hash table to score the connection of cuff_id with data index

my $line = 1; #line number in the data
my $line_number = 1;
my $column = 1; #which sample, counting from 1
$data[0][0] = "cuff_id";

open(ID,$id)||die("error with $id\n");
my $i=1;
while(<ID>){
    chomp();
    $data[$i][0] = $_; #gene id / transcript id 
    $index{$_} = $i; #index of line number
    $i++;
    $line_number++;
    next;
}

foreach my $file(@diff){
    if($file =~ /\/(WGC\d+R)/){
	$data[0][$column] = $1;
    }
    open(FILE,$file)||die("error with opening $file\n");
    while(<FILE>){
	chomp();
	if($_ !~ /test_id/){
	    my @arr = split(/\s+/,$_);
	    $line = $index{$arr[0]};
	    
	    if($arr[12] <= $qvalue){ #significant based on q_value
		if($arr[7]==0){
		    if($arr[8]==0){
			$data[$line][$column] = "*"; #0 && 0
		    }
		    else{
			$data[$line][$column] = "inf"; #0 && +, ==> +inf
		    }
		}
		else{
		    $data[$line][$column] = sprintf("%0.3f",$arr[8]/$arr[7]); #a/b
		}
	    }
	    else{
		$data[$line][$column] = "-"; #not significant
	    }
	}
	next;
    }
    close FILE;
    $column ++; #col++, another sample
}

print "$line_number\n";

for(my $i=0;$i<$line_number;$i++){
    for(my $j=0;$j<$column;$j++){
	if($j == $column-1){
	    print OUT "$data[$i][$j]\n";
	}
	else{
	    print OUT "$data[$i][$j]\t";
	}
    }
}

close OUT;
exit;
