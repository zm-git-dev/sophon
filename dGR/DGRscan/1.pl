#!/usr/bin/perl -w
use strict;

my (@files) = @ARGV;
die("usage: $0 <DRGscan Out TR-VR pair files>\n") if(@ARGV<1);

open(OUT1,">TR.fa")||die("error\n");
open(OUT2,">VR.fa")||die("error\n");
my ($id,$string,$TR,$VR) = ("","","","");
my %hash = ();
foreach my $file(@files){
    my $line=1;
    open(FILE,$file)||die("error,can't open $file\n");
    while(<FILE>){
	if($_ =~ /Template:\s+(.+)\s+strand:\s+([-\+])\s+[\d-]+/){
	    $id = $1;
	    $string = $2;
	}
	elsif($_ =~ /\d+\s+[ATCGatcg]+/){
	    my @data = split(/\s+/,$_);
	    if(($line+2) % 5 == 0){
		$TR = $data[1];
	    }
	    elsif($line % 5 == 0){
		$VR = $data[1];
		if(not exists $hash{$id}){
		    $hash{$id} = 1;
		}
		else{
		    $hash{$id} += 1;
		}
		
		my $new_id_TR = $id."_TR".$hash{$id};
		my $new_id_VR = $id."_VR".$hash{$id};
		
		print OUT1 ">$new_id_TR\n$TR\n";
		print OUT2 ">$new_id_VR\n$VR\n";
		
	    }
	}
	$line ++;
	next;
    }
    close FILE;
}

sub rev{
    my ($seq) = @_;
    my $new = "";
    for(my $i=length($seq)-1;$i >= 0;$i--){
	my $char = substr($seq,$i,1);
	if($char eq 'A' || $char eq 'a'){
	    $new .= 'T';
	}
	elsif($char eq 'T' || $char eq 't'){
            $new .= 'A';
        }
	elsif($char eq 'C' || $char eq 'c'){
            $new .= 'G';
        }
	elsif($char eq 'G' || $char eq 'g'){
            $new .= 'C';
        }
	else{
	    $new .= $char;
	}
    }
    return $new;
}

close OUT1;close OUT2;
exit;
