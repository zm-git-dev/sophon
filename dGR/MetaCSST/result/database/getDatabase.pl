#!/usr/bin/perl -w
use strict;

my ($gtf,$seq)= @ARGV;
die "Error with arguments!\nusage: $0 <GTF File> <DGR containing sequences>\n" if (@ARGV<2);

open(GTF,$gtf)||die("error with opening $gtf\n");
open(SEQ,$seq)||die("error with opening $seq\n");

open(ODGR,">DGR.txt")||die("error\n");
open(OTR,">TR.txt")||die("error\n");
open(ORT,">RT.txt")||die("error\n");
open(OPAIR,">PAIR.txt")||die("error\n");

my %seq_hash = ();
my $id = "";
while(<SEQ>){
    chomp();
    if($_ =~ />([^\s]+)/){
	$id = $1;
    }
    else{
	$seq_hash{$id} = $_;
    }
}

my ($start,$end) = (100000000000000,-1);$id = "";
my @TR = ();my @pairTR = ();my @pairVR = ();my @RT = ();
my %hash_TR = ();

my $TR_num = 1;my $TR_rank = 1;
my ($pair_TR_num,$pair_VR_num,$RT_num) = (0,0,0);

while(<GTF>){
    my @arr = split(/\s+/,$_);
    if($arr[0] ne $id){ #a new DGR system
	if($id ne ""){
	    print ODGR "$id;$start;$end\n";
	    my $dgr_seq = substr($seq_hash{$id},$start,$end-$start+1);
	    open(OTMP,">data/DGR/$id.fa")||die("error\n");
	    print OTMP ">$id\n$dgr_seq\n";
	    close OTMP;
	    
	    for(my $i=0;$i<$TR_num-1;$i++){
		print OTR "$TR[$i][0];$id;$TR[$i][1];$TR[$i][2];$TR[$i][3]\n";
		my $tr_seq = substr($seq_hash{$id},$TR[$i][1],$TR[$i][2]-$TR[$i][1]+1);
		my $tr_seq2 = $tr_seq;
		if($TR[$i][3] eq '-'){
		    $tr_seq2 = myReverse($tr_seq);
		}
		open(OTMP,">data/TR/$TR[$i][0].fa")||die("error\n");
		print OTMP ">$TR[$i][0]\n$tr_seq\n";
		close OTMP;
	    }
	    
	    for(my $i=0;$i<$RT_num;$i++){
		my $j = $i+1;
		my $rt_id = $RT[$i][0]."-RT-".$j;
		print ORT "$rt_id;$id;$RT[$i][1];$RT[$i][2];$RT[$i][3]\n";
		open(OTMP,">data/RT/$rt_id.fa")||die("error\n");
                print OTMP ">$rt_id\n$RT[$i][4]\n";
                close OTMP;
	    }

	    for(my $i=0;$i<$pair_TR_num;$i++){
		my $reID_TR = $pairTR[$i][0].".".$pairTR[$i][7];
		print OPAIR "$reID_TR;$pairTR[$i][0];$pairTR[$i][1];$pairTR[$i][2];$pairTR[$i][3];$pairVR[$i][1];$pairVR[$i][2];$pairVR[$i][3];$pairTR[$i][5];$pairTR[$i][6]\n";
		open(OTMP,">data/PAIR/$reID_TR.fa")||die("error\n");
                print OTMP ">TR\n$pairTR[$i][4]\n>VR\n$pairVR[$i][4]\n";
                close OTMP;
	    }
	}
	
	@TR = ();@pairTR = ();@pairVR = ();@RT = ();%hash_TR = ();
	$TR_num = 1;$TR_rank = 1;
	($pair_TR_num,$pair_VR_num,$RT_num) = (0,0,0);
	$id = $arr[0];
	($start,$end) = (100000000000000,-1);
    }
    if($_ =~ /\sTR\s/){
	my $tmp = $arr[0].$arr[3].$arr[4];
	if(not exists($hash_TR{$tmp})){
	    $hash_TR{$tmp} = $arr[0]."-TR-".$TR_num;
	    ($TR[$TR_num-1][0],$TR[$TR_num-1][1],$TR[$TR_num-1][2],$TR[$TR_num-1][3]) = ($arr[0]."-TR-".$TR_num,$arr[3],$arr[4],$arr[2]);
	    $TR_num ++;
	    $TR_rank = 1;
	}
	($pairTR[$pair_TR_num][0],$pairTR[$pair_TR_num][1],$pairTR[$pair_TR_num][2],$pairTR[$pair_TR_num][3],$pairTR[$pair_TR_num][4],$pairTR[$pair_TR_num][5],$pairTR[$pair_TR_num][6],$pairTR[$pair_TR_num][7]) = ($hash_TR{$tmp},$arr[5],$arr[6],$arr[2],$arr[9],$arr[7],$arr[8],$TR_rank);
	$TR_rank ++;
	$pair_TR_num ++;

	if($arr[5] < $start){$start = $arr[5]};
	if($arr[6] > $end){$end = $arr[6]};
    }
    elsif($_ =~ /\sVR\s/){
	($pairVR[$pair_VR_num][0],$pairVR[$pair_VR_num][1],$pairVR[$pair_VR_num][2],$pairVR[$pair_VR_num][3],$pairVR[$pair_VR_num][4],$pairVR[$pair_VR_num][5],$pairVR[$pair_VR_num][6]) = ("#",$arr[5],$arr[6],$arr[2],$arr[9],$arr[7],$arr[8]);
	$pair_VR_num ++;

	if($arr[5] < $start){$start = $arr[5]};
        if($arr[6] > $end){$end = $arr[6]};
    }
    elsif($_ =~ /\sRT\s/){
	($RT[$RT_num][0],$RT[$RT_num][1],$RT[$RT_num][2],$RT[$RT_num][3],$RT[$RT_num][4]) = ($arr[0],$arr[3],$arr[4],$arr[2],$arr[5]);
	if($arr[3] < $start){$start = $arr[3]};
        if($arr[4] > $end){$end = $arr[4]};
	$RT_num ++;
    }
}

print ODGR "$id;$start;$end\n";
my $dgr_seq = substr($seq_hash{$id},$start,$end-$start+1);
open(OTMP,">data/DGR/$id.fa")||die("error\n");
print OTMP ">$id\n$dgr_seq\n";
close OTMP;
    
for(my $i=0;$i<$TR_num-1;$i++){
    print OTR "$TR[$i][0];$id;$TR[$i][1];$TR[$i][2];$TR[$i][3]\n";
    my $tr_seq = substr($seq_hash{$id},$TR[$i][1],$TR[$i][2]-$TR[$i][1]+1);
    my $tr_seq2 = $tr_seq;
    if($TR[$i][3] eq '-'){
	$tr_seq2 = myReverse($tr_seq);
    }
    open(OTMP,">data/TR/$TR[$i][0].fa")||die("error\n");
    print OTMP ">$TR[$i][0]\n$tr_seq\n";
    close OTMP;
}
    
for(my $i=0;$i<$RT_num;$i++){
    my $j = $i+1;
    my $rt_id = $RT[$i][0]."-RT-".$j;
    print ORT "$rt_id;$id;$RT[$i][1];$RT[$i][2];$RT[$i][3]\n";
    open(OTMP,">data/RT/$rt_id.fa")||die("error\n");
    print OTMP ">$rt_id\n$RT[$i][4]\n";
    close OTMP;
}

for(my $i=0;$i<$pair_TR_num;$i++){
    my $reID_TR = $pairTR[$i][0].".".$pairTR[$i][7];
    print OPAIR "$reID_TR;$pairTR[$i][0];$pairTR[$i][1];$pairTR[$i][2];$pairTR[$i][3];$pairVR[$i][1];$pairVR[$i][2];$pairVR[$i][3];$pairTR[$i][5];$pairTR[$i][6]\n";
    open(OTMP,">data/PAIR/$reID_TR.fa")||die("error\n");
    print OTMP ">TR\n$pairTR[$i][4]\n>VR\n$pairVR[$i][4]\n";
    close OTMP;
}



sub myReverse{
    my ($seq) = @_;
    my $new="";
    for(my $i=length($seq)-1;$i>=0;$i--){
        my $char = substr($seq,$i,1);
        if($char eq 'A' || $char eq 'a'){$new .= 'T';}
        elsif($char eq 'T' || $char eq 't'){$new .= 'A';}
        elsif($char eq 'C' || $char eq 'c'){$new .= 'G';}
        elsif($char eq 'G' || $char eq 'g'){$new .= 'C';}
        else{
            $new .= $char;
        }
    }
    return $new;
}


close GTF;close SEQ;
close ODGR;close OTR;close ORT;close OPAIR;
exit;
