#!/usr/bin/perl -w
use strict;

my ($file)= @ARGV;
die "Error with arguments!\nusage: $0 <id.txt>\n" if (@ARGV<1);

open(FILE,$file);    
while(<FILE>){
    chomp($_);
    my $id = $_;
    system("wget https://www.ncbi.nlm.nih.gov/nuccore/$id -O $id.html");
}

exit;
