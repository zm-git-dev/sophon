#!/usr/bin/perl -w
use strict;

my ($gtf)= @ARGV;
die "Error with arguments!\nusage: $0 <GTF File>\n" if (@ARGV<1);

open(GTF,$gtf)||die("error\n"); 

my $file1 = "tmp-TR.pos.info";
my $file2 = "tmp-VR.pos.info";



close GTF;
exit;
