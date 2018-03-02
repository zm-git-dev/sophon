#!/usr/bin/perl -w
use strict;

#This program is summarize the identity as well as the length

my ($in,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <TR_VR.txt> <OUT>\n" if (@ARGV<2);

open(IN,$in)||die("can't open $in\n");
open(OUT,">$out")||die("Can't write to $out\n");

my $TR = "";


close IN;close OUT;
exit;
