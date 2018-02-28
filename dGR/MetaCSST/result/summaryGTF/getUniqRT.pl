#!/usr/bin/perl -w
use strict;

my ($fa,$out)= @ARGV;
die "Error with arguments!\nusage: $0 <RT Fa> <OUT File>\n" if (@ARGV<2);

open(FA,$fa)||die("error\n");
open(OUT,">$out")||die("error\n");

my $id = "";my %hash = ();
while(<FA>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$id = $1;
    }
    else{
	if(not exists($hash{$id})){
	    $hash{$id} = $_;
	}
	else{
	    if(length($_) > length($hash{$id})){
		$hash{$id} = $_;
	    }
	}
    }
}

foreach my $key(keys %hash){
    print OUT ">$key\n$hash{$key}\n";
}

close FA;close OUT;
exit;
