#!/usr/bin/perl -w
use strict;

my ($id,$source,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <meta-unique.id> <source.txt> <OUT File>\n" if (@ARGV<3);

open(SOURCE,$source)||die("error\n");
open(ID,$id)||die("error\n");
open(OUT,">$out")||die("error\n");

my %hash = ();

while(<SOURCE>){
    chomp();
    my @data = split(/\s+/,$_);
    if(not exists($hash{$data[0]})){
	$hash{$data[0]} = $data[1];
    }
}

while(<ID>){
    chomp();
    my $name = $_;
    if(exists($hash{$name})){
	print OUT "$name $hash{$name}\n";
    }
    else{
	print "$name\n";
    }
}

close SOURCE;close ID;close OUT;
exit;
