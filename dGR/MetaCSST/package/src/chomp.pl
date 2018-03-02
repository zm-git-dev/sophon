#!/usr/bin/perl -w
use strict;

my (@files)= @ARGV;
die "Error with arguments!\nusage: $0 <Contigs File to cut the \\n>\n" if (@ARGV<1);
foreach my $file(@files){
    my $out = $file."tmp.fa";
    open(OUT,">$out");
    if($file =~ /\.gz/){
	open(FILE,"gzip -dc $file|")||die("can't open $file\n");
	my $id="";
	my $seq="";
	while(<FILE>){
	    chomp($_);
	    if($_ =~ />/){
		if($id ne ""){
		    print OUT "$id\n$seq\n";
		}
		$id = $_;
		$seq = "";
	    }
	    elsif($_ =~ /[^\s]/){
		$seq .= $_;
	    }
	    next;
	}
	print OUT "$id\n$seq\n";
	system("gzip $out");
	system("mv $out.gz $file");
	close FILE;close OUT;
    }
    else{
	open(FILE,$file);    
	my $id="";
	my $seq="";
	while(<FILE>){
	    chomp($_);
	    if($_ =~ />/){
		if($id ne ""){
		    print OUT "$id\n$seq\n";
		}
		$id = $_;
		$seq = "";
	    }
	    else{
		$seq .= $_;
	    }
	    next;
	}
	print OUT "$id\n$seq\n";
	system("mv $out $file");
	close FILE;close OUT;
    }
}
exit;
