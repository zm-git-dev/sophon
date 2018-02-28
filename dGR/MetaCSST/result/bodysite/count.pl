#!/usr/bin/perl -w
use strict;

my ($id,@files) = @ARGV;

open(ID,$id)||die("error\n");
my %hash = ();

while(<ID>){
    chomp();
    $hash{$_} = 1;
}

foreach my $file(@files){
    open(FILE,$file)||die("error\n");
    my $num = 0;
    while(<FILE>){
	chomp();
	if(exists($hash{$_})){
	    $num ++;
	}
    }
    print "$file\t$num\n";
    close FILE;
}

exit;
