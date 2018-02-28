#!/usr/bin/perl -w
use strict;

my ($file)= @ARGV;
die "Error with arguments!\nusage: $0 <structure2.txt>\n" if (@ARGV<1);

open(FILE,$file)||die("error\n");

my %hash = ();

while(<FILE>){
    chomp();
    my @arr = split(/\s+/,$_);
    if(not exists($hash{$arr[1]})){
	my $rev = myReverse($arr[1]);
	if(not exists($hash{$rev})){
	    $hash{$arr[1]} = 1;
	}
	else{
	    $hash{$rev} += 1;
	}
    }
    else{
	$hash{$arr[1]} += 1;
    }
}

foreach my $key(keys %hash){
    print "$key\t$hash{$key}\n";
}

sub myReverse{
    my ($stru) = @_;
    my @array = split(/\./,$stru);
    my $rev = "";
    for(my $i=@array-1;$i>=0;$i--){
	if($array[$i] =~ /(.+)\+/){
	    $rev .= $1."-.";
	}
	elsif($array[$i] =~ /(.+)\-/){
	    $rev .= $1."+.";
	}
    }
    chop($rev);
    return $rev;
}

close FILE;
exit;
