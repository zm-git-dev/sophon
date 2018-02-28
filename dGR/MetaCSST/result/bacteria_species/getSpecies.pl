#!/usr/bin/perl -w
use strict;

my ($file,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <id.txt> <OUT File>\n" if (@ARGV<2);

open(FILE,$file);
open(OUT,">$out");

print OUT "id;kingdom;phylum;class;order;family;genus;species\n";
while(<FILE>){
    chomp($_);
    my $id = $_;
    my $html = "taxonomy_html/$id.html";
    open(HTML,$html)||die("error with opening $html\n");
    my ($kingdom,$phylum,$class,$order,$family,$genus,$species_group,$species) = ("#","#","#","#","#","#","#","#");
    while(<HTML>){
	if($_ =~ /"superkingdom">([^&]+)<\/[Aa]>/){
	    $kingdom = $1;
	}
	elsif($_ =~ /"phylum">([^&]+)<\/[Aa]>/){
	    $phylum = $1;
	}
	elsif($_ =~ /"class">([^&]+)<\/[Aa]>/){
            $class = $1;
        }
	elsif($_ =~ /"order">([^&]+)<\/[Aa]>/){
            $order = $1;
        }
	elsif($_ =~ /"family">([^&]+)<\/[Aa]>/){
            $family = $1;
        }
	elsif($_ =~ /"genus">([^&]+)<\/[Aa]>/){
            $genus = $1;
        }
	elsif($_ =~ /"species\s+group">([^&]+)<\/[Aa]>/){
            $species_group = $1;
        }
	elsif($_ =~ /"species">([^&]+)<\/[Aa]>/){
            $species = $1;
        }
	elsif($_ =~ /TITLE="species".+<STRONG>([^&]+)<\/STRONG>/){
	    $species = $1;
	}
    }
    #print OUT "$id;$kingdom;$phylum;$class;$order;$family;$genus;$species_group;$species\n";
    print OUT "$id;$kingdom;$phylum;$class;$order;$family;$genus;$species\n";
    close HTML;
}

exit;
