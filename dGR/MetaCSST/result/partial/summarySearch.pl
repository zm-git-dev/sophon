#!/usr/bin/perl -w
use strict;

#This script is used to summarize the TR-VR pairs in the searchVR result file,calculating the repeat number in the meanwhile 

my ($out,@files)= @ARGV;
die "Error with arguments!\nusage: $0 <OUT File> <SearchVR Result Files>\n" if (@ARGV<2);

open(OUT,">$out")||die("Error with writing to $out\n");

print OUT "ID\tmutA\tmutNA\tTR\tVR\trepeat\n";

foreach my $in(@files){
    open(IN,$in)||die("Error with opening $in\n");
    my %pair = ();
    my $tmp = "";
    my $id = "";
    if($in =~ /search\/(.+)\.out/){
	$id = $1;
    }
    
    while(<IN>){
	my @arr = split(/\s+/,$_);
	if($_ =~ /TR/){
	    $tmp = "$id\t$arr[1]\t$arr[2]\t$arr[3]\t";
	}
	elsif($_ =~ /VR/){
	    $tmp .= $arr[3];
	    if(not exists($pair{$tmp})){
		$pair{$tmp} = 1;
	    }
	    else{
		$pair{$tmp} += 1;
	    }
	}
    }
    foreach my $key(keys %pair){
	print OUT "$key\t$pair{$key}\n";
    }
    close IN;
}

close OUT;
exit;
