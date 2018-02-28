#!/usr/bin/perl -w
use strict;

my ($fa,$id,$dir)= @ARGV;
die "Error with arguments!\nusage: $0 <Fasta File> <ID> <OUT Directory>\n" if (@ARGV<3);
open(ID,$id)||die("error\n");
open(FA,$fa)||die("error\n");

my %hash = ();
while(<ID>){
    chomp();
    $hash{$_} = 1;
}

my $name = "";
while(<FA>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$name = $1;
    }
    else{
	if(exists($hash{$name})){
	    my $out = $dir.'/'.$name.".dgr.fa";
	    open(OUT,">$out")||die("error\n");
	    print OUT ">$name\n$_\n";
	    close OUT;
	}
    }
    next;
}

close ID;close FA;
exit;
