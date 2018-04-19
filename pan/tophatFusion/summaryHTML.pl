#!/usr/bin/perl -w
use strict;

## get fusion info (including fusion type, rr, rf, ff,,) from result.html

my ($out,@files)= @ARGV;
die "Error with arguments!\nusage: $0 <OUT File> <result.html(multiple file is okay)>\n" if (@ARGV<2);

open(OUT,">$out")||die("error eith writing to $out\n");
print OUT "#sample\tgene1\tchromosome\tposition\tgene2\tchromosome\tposition\tspanning_reads\tspanning_mate_reads\tspanning_mate_reads_where_one_end_spans\tfusion_type\n";

foreach my $file(@files){
    open(FILE,$file)||die("error with opening $file\n");
    my $type = "";
    my @arr = ();
    while(<FILE>){
	chomp();
	if($_ =~ /^\d+\.\s+[^\s]+\s+([rf]+)/){
	    $type = $1;
	}
	elsif($_ =~ /<\/TR>/){
	    foreach my $i(@arr){
		print OUT "$i\t";
	    }
	    print OUT "$type\n";
	    @arr = ();
	}
	elsif($_ =~ /<TD/){
	    if($_ =~ />([^\s]+)</){
		push(@arr,$1);
	    }
	}
	    
    }
    close FILE;
}
close OUT;
exit;
