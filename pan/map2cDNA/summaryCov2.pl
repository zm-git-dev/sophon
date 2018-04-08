#!/usr/bin/perl -w
use strict;

my ($ref,$coverage,$out,@files)= @ARGV;
die "Error with arguments!\nusage: $0 <Ref CDS> <Coverage cuttof> <OUT File> <*.cov.txt>\n" if (@ARGV<4);

my %len = ();
open(REF,$ref)||die("error\n");
open(OUT,">$out")||die("error\n");
my $id = "";
while(<REF>){
    chomp();
    if($_ =~ />([^\s]+)/){$id = $1;}
    else{
	if(not exists($len{$id})){
	    $len{$id} = length($_);
	}
    }
}

print OUT "Sample\t";

my @gene = keys %len;
foreach my $key(@gene){
    print OUT "$key\t";
}
print OUT "\n";

foreach my $file(@files){
    my $sample = "";
    if($file =~ /cov\/([^\s]+)\.cov\.txt/){
	$sample = $1;
    }
    else{
	die("error with sample $file\n");
    }
    
    open(FILE,$file);    
    my %this = ();
    $id = "";
    my @start = ();
    my @end = ();
    while(<FILE>){
	chomp($_);
	my @data = split(/\s+/,$_);
	if($id eq ""){
	    $id = $data[0];
	    push(@start,$data[1]);push(@end,$data[2]);  ##first cds
	}
	else{
	    if($data[0] ne $id){  ##new cds

		my $size = @start;
		my $cov_len = 0;
		for(my $i=0;$i<$size;$i++){
		    $cov_len += $end[$i]-$start[$i]+1;
		}
		my $cov = sprintf("%0.2f",$cov_len/$len{$id});
		$this{$id} = $cov;

		$id = $data[0];@start = ();@end = ();
		push(@start,$data[1]);push(@end,$data[2]);
	    }
	    else{
		my $size = @start;
		if($data[1] > $end[$size-1]){ #no overlap
		    push(@start,$data[1]);push(@end,$data[2]);
		}
		else{
		    if($data[2] > $end[$size-1]){
			$end[$size-1] = $data[2];
		    }
		}
	    }
	}
    }
    if(@start != 0){
	my $size = @start;
	my $cov_len = 0;
	for(my $i=0;$i<$size;$i++){
	    $cov_len += $end[$i]-$start[$i];
	}
	my $cov = sprintf("%0.2f",$cov_len/$len{$id});
	$this{$id} = $cov;
    }
    close FILE;

    print OUT "$sample\t";
    foreach my $key(@gene){
        if(exists($this{$key}) && $this{$key} > $coverage){
	    print OUT "1\t";
        }
        else{
            print OUT "0\t";
        }
    }

    print OUT "\n";
}
close OUT;
exit;
