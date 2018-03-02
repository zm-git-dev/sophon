#!/usr/bin/perl -w
use strict;

my ($file,$out) = @ARGV;
die "Error with arguments!\nusage: $0 <Annotate GTF File> <OUT File>\n" if (@ARGV<2);

open(FILE,$file)||die("error with opening $file\n");
open(OUT,">$out")||die("error with writing to $out\n");

my $id = "";
my @data = ();
my $line = 0;

while(<FILE>){
    chomp();
    my @arr = split(/\s+/,$_);
    if($_ =~ /RT/){
	$line = 0;
	if($id eq ""){
	    $id = $arr[0];
	    $data[0][0] = $arr[0];
	    $data[0][1] = $arr[1];
	    $data[0][2] = $arr[2];
	    $data[0][3] = $arr[3];
	}
	else{
	    print "$id\t";
	    
	    @data = ();
	    $data[0][0] = $arr[0];
            $data[0][1] = $arr[1];
            $data[0][2] = $arr[2];
            $data[0][3] = $arr[3];

	}
    }
    else{
    }
    $line++;
    next;
}
