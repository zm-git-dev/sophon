#!/usr/bin/perl -w
use strict;

#This program is used to generate a contingency table to run chi-square test

my ($cassette,$phylum)= @ARGV;
die "Error with arguments!\nusage: $0 <Cassette classification> <Phylum classification>\n" if (@ARGV<2);

open(FILE1,$cassette)||die("error\n");
open(FILE2,$phylum)||die("error\n");

my %line = ("G1"=>1,"G2"=>2,"G3"=>3,"G4"=>4,"G5"=>5,"G6"=>6,"G7"=>7,"G8"=>8,"G9"=>9,"others"=>10);
my %column = ("Proteobacteria"=>1,"Firmicutes"=>2,"Actinobacteria"=>3,"Bacteroidetes"=>4,"Cyanobacteria"=>5,"others"=>6);

my @data = ();
$data[0][0] = "Table";
for(my $i=1;$i<=9;$i++){
    $data[$i][0] = "G$i";
}
$data[10][0]="others";
$data[0][1]="Proteobacteria";$data[0][2]="Firmicutes";$data[0][3]="Actinobacteria";$data[0][4]="Bacteroidetes";$data[0][5]="Cyanobacteria";$data[0][6]="others";

for(my $i=1;$i<=10;$i++){
    for(my $j=1;$j<=6;$j++){
	$data[$i][$j] = 0;
    }
}

my %CASSETTE = ();
while(<FILE1>){
    chomp();
    my @arr = split(/\s+/,$_);
    $CASSETTE{$arr[0]} = $arr[1];
}

while(<FILE2>){
    chomp();
    my @arr = split(/\s+/,$_);
    
    my $this_line = $line{$CASSETTE{$arr[0]}};
    my $this_column = $column{$arr[1]};
    $data[$this_line][$this_column] += 1;
}

for(my $i=0;$i<=10;$i++){
    for(my $j=0;$j<=6;$j++){
        print "$data[$i][$j]\t";
    }
    print "\n";
}

close FILE1;close FILE2;
exit;
