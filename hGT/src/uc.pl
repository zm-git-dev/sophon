#!/usr/bin/perl -w
use strict;

## convertion to the upercase with FASTA sequence

my ($fa,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <Input fasta> <OUT File>\n" if (@ARGV<2);

open(FA,$fa)||die("error\n");
open(OUT,">$out")||die("error\n");

while(<FA>){
    chomp();
    if($_ =~ />/){
	print OUT "$_\n";
    }
    else{
	my $seq = uc($_);
	print OUT "$seq\n";
    }
    next;
}

close FA;close OUT;
exit;
