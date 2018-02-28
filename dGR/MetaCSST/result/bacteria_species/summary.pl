#!/usr/bin/perl -w
use strict;

my ($id,$file)= @ARGV;
die "Error with arguments!\nusage: $0 <Non-redundant IDs> <species.txt>\n" if (@ARGV<2);

open(ID,$id)||die("erron\n");
my %unique = ();
while(<ID>){
    chomp();
    $unique{$_} = 1;
}

my %kingdom = ();
my %phylum = ();
my %class = ();
my %order = ();
my %family = ();
my %genus = ();
my %species = ();
open(FILE,$file)||die("error\n");
while(<FILE>){
    chomp($_);
    if($_ !~ /id;/){
	my @arr = split(/;/,$_);
	if(exists($unique{$arr[0]})){
	    if(not exists($arr[1])){$kingdom{$arr[1]} = 1;}
	    else{$kingdom{$arr[1]} += 1;}
	    
	    if(not exists($arr[2])){$phylum{$arr[2]} = 1;}
	    else{$phylum{$arr[2]} += 1;}
	    
	    if(not exists($arr[3])){$class{$arr[3]} = 1;}
	    else{$class{$arr[3]} += 1;}
	    
	    if(not exists($arr[4])){$order{$arr[4]} = 1;}
	    else{$order{$arr[4]} += 1;}
	    
	    if(not exists($arr[5])){$family{$arr[5]} = 1;}
	    else{$family{$arr[5]} += 1;}
	    
	    if(not exists($arr[6])){$genus{$arr[6]} = 1;}
	    else{$genus{$arr[6]} += 1;}
	    
	    if(not exists($arr[7])){$species{$arr[7]} = 1;}
	    else{$species{$arr[7]} += 1;}
	}
    }
}

print "######kingdom######\n";
foreach my $key(keys %kingdom){
    print "$key\t$kingdom{$key}\n";
}

print "######phylum######\n";
foreach my $key(keys %phylum){
    print "$key\t$phylum{$key}\n";
}

print "######class######\n";
foreach my $key(keys %class){
    print "$key\t$class{$key}\n";
}

print "######order######\n";
foreach my $key(keys %order){
    print "$key\t$order{$key}\n";
}

print "######family######\n";
foreach my $key(keys %family){
    print "$key\t$family{$key}\n";
}

print "######genus######\n";
foreach my $key(keys %genus){
    print "$key\t$genus{$key}\n";
}

print "######species######\n";
foreach my $key(keys %species){
    print "$key\t$species{$key}\n";
}
close ID;close FILE;
exit;
