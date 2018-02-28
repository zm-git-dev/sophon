#!/usr/bin/perl -w
use strict;

my (@files) = @ARGV;
die "Error with arguments!\nusage: $0 <Result by DiGReF>\n" if (@ARGV<1);
open(DGR,">DGR.fa")||die("can't write to DGR.fa\n");
open(RT,">RT.fa")||die("can't write to RT.fa\n");
open(TR,">TR.fa")||die("can't write to TR.fa\n");
open(VR,">VR.fa")||die("can't write to VR.fa\n");

foreach my $file(@files){
    open(FILE,$file)||die("can't open $file\n");
    my $id="";
    my(@tr,@vr)=((),());
    if($file =~ /(\d+)\.txt/){
	$id = "gi".$1;
    }
    my @line=<FILE>;
    if(@line > 9){
	print DGR ">$id\n$line[3]";
	print RT ">$id\n$line[1]";
	for(my $i=5;$i<@line;$i++){
	    if($line[$i] =~ />(TR\d+)/){
		my $name = ">$id"."_"."$1";
		print TR "$name\n$line[$i+1]";
	    }
	    elsif($line[$i] =~ />(VR\d+)/){
                my $name = ">$id"."_"."$1";
                print VR "$name\n$line[$i+1]";
            }
	    
	}
    }
    close FILE;
}
close TR;close VR;close RT;close DGR;
exit;
