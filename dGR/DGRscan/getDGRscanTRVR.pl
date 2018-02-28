#!/usr/bin/perl -w
use strict;

my (@files) = @ARGV;
die("usage: $0 <DRGscan Out TR-VR pair files>\n") if(@ARGV<1);

open(OUT,">DGRscanTRVR.gtf")||die("error\n");

my $id = "";
my ($TR,$stringTR,$startTR,$endTR,$lengthTR) = ("","",-1,-1,-1);
my ($VR,$stringVR,$startVR,$endVR,$lengthVR) = ("","",-1,-1,-1);
my %hash = ();

foreach my $file(@files){
    my $line=1;
    open(FILE,$file)||die("error,can't open $file\n");
    while(<FILE>){
	if($_ =~ /Template:\s+(.+)\s+strand:\s+([-\+])\s+(\d+)-(\d+)/){
	    $id = $1;
	    $stringTR = $2;
	    $startTR = $3;
	    $endTR = $4;
	    $lengthTR = $endTR-$startTR+1;
	}
	elsif($_ =~ /Variable:\s+(.+)\s+strand:\s+([-\+])\s+(\d+)-(\d+)/){
            $stringVR = $2;
            $startVR = $3;
            $endVR = $4;
	    $lengthVR = $endVR-$startVR+1;
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
		
		my $new_TR = rev($TR,$stringTR);
		my $new_VR = rev($VR,$stringVR);

		print OUT "$new_id_TR\tTR\t$startTR\t$endTR\t$lengthTR\t$new_TR\n";
		print OUT "$new_id_VR\tVR\t$startVR\t$endVR\t$lengthVR\t$new_VR\n";
	    }
	}
	$line ++;
	next;
    }
    close FILE;
}

sub rev{
    my ($seq,$string) = @_;
    if($string eq "+"){
	return $seq;
    }
    else{
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
}

close OUT;
exit;
