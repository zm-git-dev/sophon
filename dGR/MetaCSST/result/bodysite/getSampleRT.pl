#!/usr/bin/perl -w
use strict;

#this script is used to get the RTs for the body sites

open(INFO,"sample.info")||die("error\n");
open(YES,"yesID.txt")||die("error\n");

my %yes = ();  ##samples with DGR systems
while(<YES>){
    chomp();
    $yes{$_} = 1;
}

my %hash = ();
while(<INFO>){
    chomp();
    my ($body_site,$sample) = split(/\s+/,$_);
    if(exists($yes{$sample})){
	open(SAMPLE,"HMASM/$sample.gtf")||die("error\n");
	while(<SAMPLE>){
	    chomp();
	    if($_ =~ /DGR/){
		my @arr = split(/\s+/,$_);
		my $id = $arr[0];
		if(not exists($hash{$id})){
		    $hash{$id} = $body_site;
		}
	    }
	}
	close SAMPLE;
    }
}

foreach my $key(keys %hash){
    my $site = $hash{$key};
    print "grep $key /share/home/user/fzyan/dGR/MetaCSST/result/HMASM-rebuild.gtf |grep \"RT\" |awk '{print \">\"\$1\"\\n\"\$6}' >> RT/$site.RT.fa\n";
}

close INFO;
exit
