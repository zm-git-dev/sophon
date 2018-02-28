#!/usr/bin/perl -w
use strict;

my ($id,$info,@files) = @ARGV;

open(ID,$id)||die("error\n");
open(INFO,$info)||die("error\n");

my %hash = ();
while(<ID>){
    chomp();
    $hash{$_} = 1;
}

my %body = ();
while(<INFO>){
    chomp();
    my @data = split(/\s+/,$_);
    $body{$data[1]} = $data[0];
}

foreach my $file(@files){
    open(FILE,$file)||die("error\n");
    my $id = "";
    if($file =~ /(SRS\d+)\.id/){
	$id = $1;
    }
    while(<FILE>){
	chomp();
	if(exists($hash{$_})){
	    print "$_ $body{$id}\n";
	}
    }
    close FILE;
}

exit;
