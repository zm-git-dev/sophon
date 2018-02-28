#!/usr/bin/perl -w
# DiGRef v1 - Program to find diversity generating retroelements - 26. April 2012
# Written by Mohamed Lisfi, Department of Genetics, University of Kaiserslautern,
# Postfach 3049, 67653 Kaiserslautern, Germany.
# Email contact: cullum@rhrk.uni-kl.de

use strict;
use warnings;


# bioperl must be installed for the following:
# for details of installing bioperl see: www.bioperl.org

use Bio::DB::GenBank ;
use Bio::SeqIO;
use Bio::Seq;
use Bio::Seq::RichSeq;
use Bio::Tools::SeqStats;

#*****************************************************************************
#***          USING THE PROGRAM WITH DEFAULT PARAMETERS                    ***
#
# The program needs a text input file GI.txt, which lists the GI numbers of
# GenBank protein sequences (i.e. RT sequences)
# The analysis of each sequence is output as its own text file with
# the name <GI number>.txt
# The RT protein entry is downloaded from NCBI and used to find the
# corresponding DNA sequence from the DBSOURCE field
# The output coordinates for the TR and VR are the coordinates in the
# DNA sequence
# If you want to produce a GenBank format entry that can be viewed in a
# sequence viewer program such as Artemis, you must run the accompanying
# program convertGB.pl
#
#*****************************************************************************

#*****************************************************************************
#***                       CHANGING PARAMETERS                             ***
#
# You must alter the source code as detailed below


#*****************************************************************************
#***                    CHANGING INPUT FILE NAME                           ***
#
my $input = 'GI.txt'; # change GI.txt to required name

#*****************************************************************************
#***                    CHANGING MUTABLE BASE                              ***
#
my $b = 'A'; # change A to C, G or T

#*****************************************************************************
#***                    CHANGING LENGTH OF REGION                          ***
#***                  TO BE SEARCHED FOR TR AND VR                         ***
#
# default is 5000 bp up- and downstream of each RT
#
my $seqRTseq = 5000; # change to number of bp needed

#*****************************************************************************
#***                    CHANGING MINIMUM NUMBER                            ***
#***                      OF A-RESIDUES in TR                              ***
#
# default is at least 10 A-residues
#
my $basenumb = 10; # change to required number

#*****************************************************************************
#***                    CHANGING MINIMUM NUMBER                            ***
#***                     OF SUBSTITUTIONS IN VR                            ***
#
# default is at least 7 substitutions of A-residues
#
my $subs = 7; # change to required number

#*****************************************************************************
#*****************************************************************************



# the file contains a list of GI-numbers that will be investigated with the program
# give the inputfile
open (INFILE, "<$input") or die "Can't open input file, $!\n";

my @Inlines = <INFILE>; # all lines in the file

foreach my $GI_number (@Inlines) # each line contains one GI-number
{
chomp $GI_number;

# OUTFILEput files will be appointed by GI-numbers
# with text document (.txt) format
open (OUTFILE, ">$GI_number.txt");

   my $gi= "$GI_number"; # GI-number

   my $db = Bio::DB::GenBank->new;

my $seq_obj = $db->get_Seq_by_gi($gi); # search by GI-number

   my $OUTFILEput_seq = Bio::SeqIO ->new( -format => 'genbank'); # read from file

 # get a seqfeature somehow, eg, from a Sequence with Features attached
 # array of sub Sequence Features
   my @features = $seq_obj->get_SeqFeatures;
   
   foreach my $feature (@features) {
   
      next unless($feature->primary_tag eq 'CDS'); #  primary tag for a feature 'CDS'
      if ($feature->has_tag('coded_by')) {
                (my $coded_by) = $feature->get_tag_values('coded_by'); # value of the specified tag
                
          # for complement
          if ($coded_by =~m/complement\((.+)\)/) {
          $1 =~m/(.+):\W*(\d+)\.\.\W*(\d+)/;
          print OUTFILE "RT complement($2..$3)\t";

          &comprt($1,$2+2,$3-1,$seqRTseq);
          &comptrvr($1,$2+2,$3-1,$subs,$basenumb,$b);
          }

          # for upstream
          else {
          $coded_by =~m/(.+):\W*(\d+)\.\.\W*(\d+)/;
          print OUTFILE "RT $2..$3\t";

          &rt($1,$2,$3,$subs,$basenumb,$seqRTseq,$b);
          }
        }
   }
}

# subroutin to get RT coordinates in complement
sub comprt {

   my ($dbsourcs,$start,$end,$seqRTseq) = @_;
   my $db = Bio::DB::GenBank->new;
   my $seq_obj = $db->get_Seq_by_acc($dbsourcs);
   my $genome_seq = Bio::SeqIO ->new( -format => 'fasta');
   my $genome = $seq_obj->seq;
   my $genomelen = $seq_obj->length;
   print "$genome\n\n\n";

   $genome=~s/\s//g;
   
   my $len = $end-$start+1;
   my $rtdna = substr($genome,$start,$len);
   
   $rtdna =~tr/ATCG/TAGC/;
   $genome =~tr/ATCG/TAGC/;
   $genome = reverse($genome);
   $rtdna = reverse($rtdna);
   
   my $seq = "";
   my $start_seq;
   
   while($genome=~m/$rtdna/gi)
   {
   $end = pos($genome);
   $start = $end-$len+1;
   
       # sometimes the TR is localized at the extremity of complementary genome, in a position less than 5000 bases
       # in the loop, it is assumed that the position superior to 5000 bases,
       # if that it is true, $i is equal to 5000, and the start position of DNA sequence is equal to ($start - 5000)
       # if not, a number lower than 5000 will be sought, in such a way that the start position of DNA sequence is equal to 1
           for (my $i = $seqRTseq/2 ; $i<= $seqRTseq/2 ; $i--) {
           $start_seq = $start-$i;
                    if ( 0 < $start_seq){
                    $seq = substr($genome,$start_seq,$len+$seqRTseq);
                    last
                 }
           }
}

   my $seqlen=length($seq);

print OUTFILE "length of genome: $genomelen\n$rtdna\n\n$seq\n\n";
}

# subroutin to get TR and VR coordinates in complement
sub comptrvr {

   my ($dbsourcs, $end, $start, $subs, $basenumb, $b) = @_;
   my $db = Bio::DB::GenBank->new;
   my $seq_obj = $db->get_Seq_by_acc($dbsourcs);
   my $genome_seq = Bio::SeqIO ->new( -format => 'fasta');
   my $genome = $seq_obj->seq;
   
   $genome=~s/\s//g;
   
   my $len = $end-$start+1;
   my $rtdna= substr($genome,$start,$len);
   
   $rtdna=~tr/ATCG/TAGC/;
   $genome=~tr/ATCG/TAGC/;
   $genome=reverse($genome);
   $rtdna=reverse($rtdna);
   
   my $seq = "";
   my $start_seq;
   
   while($genome=~m/$rtdna/gi)
   {
   $end = pos($genome);
   $start = $end-$len+1;
   
   # loop to find the exact coordinates of TR and VR as used in sub comprt
          for (my $i = $seqRTseq/2 ; $i<= $seqRTseq/2 ; $i--) {
               $start_seq = $start-$i;
                    if ( 0 < $start_seq){
                    $seq = substr($genome,$start_seq,$len+$seqRTseq);
                    last
                 }
           }
}

   my $seqlen=length($seq);

&findrepeat($start, $seq, $seqlen, $genome, $subs, $basenumb, $b);
}

# subroutin to get coordinates of RT in upstream
sub rt {

   my ($dbsourcs, $start, $end, $subs, $basenumb, $seqRTseq, $b) = @_;

   my $db = Bio::DB::GenBank->new;
   my $seq_obj = $db->get_Seq_by_acc($dbsourcs);
   my $genome_seq = Bio::SeqIO ->new( -format => 'fasta');
   my $genome = $seq_obj->seq;
   my $genomelen = $seq_obj->length;
   
   $genome=~s/\s//g;
   
   my $len = $end-$start+1;
   my $start_seq;
   my $seq;

      # in some genomes the TR is localized at the beginning, in a position less than 5000 bases
      # in the loop, the correct position being sought, as well as in sub comprt
      for (my $i = $seqRTseq/2 ; $i<= $seqRTseq/2 ; $i--) {
           $start_seq = $start-$i;
                    if ( 0 < $start_seq){
                    $seq = substr($genome,$start_seq,$len+$seqRTseq);
                    last
                 }
           }

   my $seqlen=length($seq);
   my $rtdna= substr($genome,$start-1,$len-3);
   print OUTFILE "length of genome: $genomelen\n$rtdna\n\n$seq\n\n";

&findrepeat($start, $seq, $seqlen, $genome, $subs, $basenumb, $b);
}

# subroutin to find repeats
sub findrepeat
{
  my($start, $seq, $seqlen, $genome, $subs, $basenumb, $b) = @_;
  my @TR_pos = "";
  my @VR_pos = "";

   # get repeat position; ATTENTION: Some of the TR position have two (or more) VRs, we have to seperate them
     for (my $n=1; $n <= $seqlen-100; $n++) {
      my $bp= substr($seq,$n,50);
      $bp =~ s/$b/[ACGT]/gi;
        while ($seq =~m/$bp/gi) {
          my $bppos=pos($seq)-50;

          if ($bppos == $n ){next}
          elsif (abs($bppos-$n)<=50){next}
          else {
              my $start_seq;
              for (my $i = $seqRTseq/2 ; $i<= $seqRTseq/2 ; $i--){
                      $start_seq = $start-$i;
                      if ( 0 < $start_seq){
                      my $trpos= $start-$i+$n;
                      my $vrpos= $start-$i+$bppos;
                              if (0 < $trpos){
                              push(@TR_pos, $trpos);
                              push(@VR_pos, $vrpos);
                              }
                      last
                      }
              }
          }
         }
      }
     
my $scalarpos = scalar (@TR_pos);

# to give signals if there exist no TR and VR
if ($scalarpos <= 3){print OUTFILE "no TR and VR!\n";}

else {   # if there is repeat

# the programm can interpret up to 20 repeats
# the number that ends the name of each array, means the number of repeats
# each array contains corresponding position of TR and VR
my @TR_1 = "";
my @TR_2 = "";
my @TR_3 = "";
my @TR_4 = "";
my @TR_5 = "";
my @TR_6 = "";
my @TR_7 = "";
my @TR_8 = "";
my @TR_9 = "";
my @TR_10 = "";
my @TR_11 = "";
my @TR_12 = "";
my @TR_13 = "";
my @TR_14 = "";
my @TR_15 = "";
my @TR_16 = "";
my @TR_17 = "";
my @TR_18 = "";
my @TR_19 = "";
my @TR_20 = "";

my @VR_1 = "";
my @VR_2 = "";
my @VR_3 = "";
my @VR_4 = "";
my @VR_5 = "";
my @VR_6 = "";
my @VR_7 = "";
my @VR_8 = "";
my @VR_9 = "";
my @VR_10 = "";
my @VR_11 = "";
my @VR_12 = "";
my @VR_13 = "";
my @VR_14 = "";
my @VR_15 = "";
my @VR_16 = "";
my @VR_17 = "";
my @VR_18 = "";
my @VR_19 = "";
my @VR_20 = "";

 # to push positions of TRs and VRs in arrays
MYLOOP: for (my $n = 1; $n < $scalarpos-1; $n++) {
                for (my $m=1; $m<=20; $m++) { # $m: possible number of repeat
                    # prerequisite to put positions in the correct array according to number of repeat
                    # for first position
                    if ($n==1) {
                       if ($TR_pos[$n] != $TR_pos[$n+$m]) {
                       for (my $k = 0; $k < $m; $k++) {
                                if ($m==1){ push (@TR_1, $TR_pos[$n+$k]); push (@VR_1, $VR_pos[$n+$k]);}
                                if ($m==2){ push (@TR_2, $TR_pos[$n+$k]); push (@VR_2, $VR_pos[$n+$k]);}
                                if ($m==3){ push (@TR_3, $TR_pos[$n+$k]); push (@VR_3, $VR_pos[$n+$k]);}
                                if ($m==4){ push (@TR_4, $TR_pos[$n+$k]); push (@VR_4, $VR_pos[$n+$k]);}
                                if ($m==5){ push (@TR_5, $TR_pos[$n+$k]); push (@VR_5, $VR_pos[$n+$k]);}
                                if ($m==6){ push (@TR_6, $TR_pos[$n+$k]); push (@VR_6, $VR_pos[$n+$k]);}
                                if ($m==7){ push (@TR_7, $TR_pos[$n+$k]); push (@VR_7, $VR_pos[$n+$k]);}
                                if ($m==8){ push (@TR_8, $TR_pos[$n+$k]); push (@VR_8, $VR_pos[$n+$k]);}
                                if ($m==9){ push (@TR_9, $TR_pos[$n+$k]); push (@VR_9, $VR_pos[$n+$k]);}
                                if ($m==10){ push (@TR_10, $TR_pos[$n+$k]); push (@VR_10, $VR_pos[$n+$k]);}
                                if ($m==11){ push (@TR_11, $TR_pos[$n+$k]); push (@VR_11, $VR_pos[$n+$k]);}
                                if ($m==12){ push (@TR_12, $TR_pos[$n+$k]); push (@VR_12, $VR_pos[$n+$k]);}
                                if ($m==13){ push (@TR_13, $TR_pos[$n+$k]); push (@VR_13, $VR_pos[$n+$k]);}
                                if ($m==14){ push (@TR_14, $TR_pos[$n+$k]); push (@VR_14, $VR_pos[$n+$k]);}
                                if ($m==15){ push (@TR_15, $TR_pos[$n+$k]); push (@VR_15, $VR_pos[$n+$k]);}
                                if ($m==16){ push (@TR_16, $TR_pos[$n+$k]); push (@VR_16, $VR_pos[$n+$k]);}
                                if ($m==17){ push (@TR_17, $TR_pos[$n+$k]); push (@VR_17, $VR_pos[$n+$k]);}
                                if ($m==18){ push (@TR_18, $TR_pos[$n+$k]); push (@VR_18, $VR_pos[$n+$k]);}
                                if ($m==19){ push (@TR_19, $TR_pos[$n+$k]); push (@VR_19, $VR_pos[$n+$k]);}
                                if ($m==20){ push (@TR_20, $TR_pos[$n+$k]); push (@VR_20, $VR_pos[$n+$k]);}
                       }
                       next MYLOOP
                    }
                }
                
                # prerequisite to put positions in the correct array according to number of repeat
                # for next positions
                elsif (1 < $n) {
                          unless ($TR_pos[$n] == $TR_pos[$n-1]) {
                          unless ($TR_pos[$n] == $TR_pos[$n+$m]) {
                            for (my $k = 0; $k<$m; $k++) {
                                if ($m==1){ push (@TR_1, $TR_pos[$n+$k]); push (@VR_1, $VR_pos[$n+$k]);}
                                if ($m==2){ push (@TR_2, $TR_pos[$n+$k]); push (@VR_2, $VR_pos[$n+$k]);}
                                if ($m==3){ push (@TR_3, $TR_pos[$n+$k]); push (@VR_3, $VR_pos[$n+$k]);}
                                if ($m==4){ push (@TR_4, $TR_pos[$n+$k]); push (@VR_4, $VR_pos[$n+$k]);}
                                if ($m==5){ push (@TR_5, $TR_pos[$n+$k]); push (@VR_5, $VR_pos[$n+$k]);}
                                if ($m==6){ push (@TR_6, $TR_pos[$n+$k]); push (@VR_6, $VR_pos[$n+$k]);}
                                if ($m==7){ push (@TR_7, $TR_pos[$n+$k]); push (@VR_7, $VR_pos[$n+$k]);}
                                if ($m==8){ push (@TR_8, $TR_pos[$n+$k]); push (@VR_8, $VR_pos[$n+$k]);}
                                if ($m==9){ push (@TR_9, $TR_pos[$n+$k]); push (@VR_9, $VR_pos[$n+$k]);}
                                if ($m==10){ push (@TR_10, $TR_pos[$n+$k]); push (@VR_10, $VR_pos[$n+$k]);}
                                if ($m==11){ push (@TR_11, $TR_pos[$n+$k]); push (@VR_11, $VR_pos[$n+$k]);}
                                if ($m==12){ push (@TR_12, $TR_pos[$n+$k]); push (@VR_12, $VR_pos[$n+$k]);}
                                if ($m==13){ push (@TR_13, $TR_pos[$n+$k]); push (@VR_13, $VR_pos[$n+$k]);}
                                if ($m==14){ push (@TR_14, $TR_pos[$n+$k]); push (@VR_14, $VR_pos[$n+$k]);}
                                if ($m==15){ push (@TR_15, $TR_pos[$n+$k]); push (@VR_15, $VR_pos[$n+$k]);}
                                if ($m==16){ push (@TR_16, $TR_pos[$n+$k]); push (@VR_16, $VR_pos[$n+$k]);}
                                if ($m==17){ push (@TR_17, $TR_pos[$n+$k]); push (@VR_17, $VR_pos[$n+$k]);}
                                if ($m==18){ push (@TR_18, $TR_pos[$n+$k]); push (@VR_18, $VR_pos[$n+$k]);}
                                if ($m==19){ push (@TR_19, $TR_pos[$n+$k]); push (@VR_19, $VR_pos[$n+$k]);}
                                if ($m==20){ push (@TR_20, $TR_pos[$n+$k]); push (@VR_20, $VR_pos[$n+$k]);}
                            }
                            next MYLOOP
                         }
                      }
                }
        }
}

# number of positions in each array
my $sca1 = scalar (@TR_1);
my $sca2 = scalar (@TR_2);
my $sca3 = scalar (@TR_3);
my $sca4 = scalar (@TR_4);
my $sca5 = scalar (@TR_5);
my $sca6 = scalar (@TR_6);
my $sca7 = scalar (@TR_7);
my $sca8 = scalar (@TR_8);
my $sca9 = scalar (@TR_9);
my $sca10 = scalar (@TR_10);
my $sca11 = scalar (@TR_11);
my $sca12 = scalar (@TR_12);
my $sca13 = scalar (@TR_13);
my $sca14 = scalar (@TR_14);
my $sca15 = scalar (@TR_15);
my $sca16 = scalar (@TR_16);
my $sca17 = scalar (@TR_17);
my $sca18 = scalar (@TR_18);
my $sca19 = scalar (@TR_19);
my $sca20 = scalar (@TR_20);

# arrays with the first position and the last position for successive positions
my @TR_nr1 = "";
my @TR_nr2 = "";
my @TR_nr3 = "";
my @TR_nr4 = "";
my @TR_nr5 = "";
my @TR_nr6 = "";
my @TR_nr7 = "";
my @TR_nr8 = "";
my @TR_nr9 = "";
my @TR_nr10 = "";
my @TR_nr11 = "";
my @TR_nr12 = "";
my @TR_nr13 = "";
my @TR_nr14 = "";
my @TR_nr15 = "";
my @TR_nr16 = "";
my @TR_nr17 = "";
my @TR_nr18 = "";
my @TR_nr19 = "";
my @TR_nr20 = "";

my @VR_nr1 = "";
my @VR_nr2 = "";
my @VR_nr3 = "";
my @VR_nr4 = "";
my @VR_nr5 = "";
my @VR_nr6 = "";
my @VR_nr7 = "";
my @VR_nr8 = "";
my @VR_nr9 = "";
my @VR_nr10 = "";
my @VR_nr11 = "";
my @VR_nr12 = "";
my @VR_nr13 = "";
my @VR_nr14 = "";
my @VR_nr15 = "";
my @VR_nr16 = "";
my @VR_nr17 = "";
my @VR_nr18 = "";
my @VR_nr19 = "";
my @VR_nr20 = "";

# to add only the first and last position for successive positions in the array
for (my $k=0; $k<1; $k++) {push (@TR_nr1, $TR_1[$k+1]); push (@VR_nr1, $VR_1[$k+1]); for (my $n=1; $n<scalar(@TR_1)-1; $n = $n+1) {my $i = $n + 1; if (($TR_1[$n+$k]!= $TR_1[$i+$k]-1) || ($VR_1[$n+$k]!= $VR_1[$i+$k]-1)){push (@TR_nr1, $TR_1[$n+$k]);push (@TR_nr1, $TR_1[$i+$k]); push (@VR_nr1, $VR_1[$n+$k]);push (@VR_nr1, $VR_1[$i+$k]);}}push (@TR_nr1, $TR_1[$k-1]);push (@VR_nr1, $VR_1[$k-1]);}
for (my $k=0; $k<2; $k++) {push (@TR_nr2, $TR_2[$k+1]); push (@VR_nr2, $VR_2[$k+1]); for (my $n=1; $n<scalar(@TR_2)-2; $n = $n+2) {my $i = $n + 2; if (($TR_2[$n+$k]!= $TR_2[$i+$k]-1) || ($VR_2[$n+$k]!= $VR_2[$i+$k]-1)){push (@TR_nr2, $TR_2[$n+$k]);push (@TR_nr2, $TR_2[$i+$k]); push (@VR_nr2, $VR_2[$n+$k]);push (@VR_nr2, $VR_2[$i+$k]);}}push (@TR_nr2, $TR_2[$k-2]);push (@VR_nr2, $VR_2[$k-2]);}
for (my $k=0; $k<3; $k++) {push (@TR_nr3, $TR_3[$k+1]); push (@VR_nr3, $VR_3[$k+1]); for (my $n=1; $n<scalar(@TR_3)-3; $n = $n+3) {my $i = $n + 3; if (($TR_3[$n+$k]!= $TR_3[$i+$k]-1) || ($VR_3[$n+$k]!= $VR_3[$i+$k]-1)){push (@TR_nr3, $TR_3[$n+$k]);push (@TR_nr3, $TR_3[$i+$k]); push (@VR_nr3, $VR_3[$n+$k]);push (@VR_nr3, $VR_3[$i+$k]);}}push (@TR_nr3, $TR_3[$k-3]);push (@VR_nr3, $VR_3[$k-3]);}
for (my $k=0; $k<4; $k++) {push (@TR_nr4, $TR_4[$k+1]); push (@VR_nr4, $VR_4[$k+1]); for (my $n=1; $n<scalar(@TR_4)-4; $n = $n+4) {my $i = $n + 4; if (($TR_4[$n+$k]!= $TR_4[$i+$k]-1) || ($VR_4[$n+$k]!= $VR_4[$i+$k]-1)){push (@TR_nr4, $TR_4[$n+$k]);push (@TR_nr4, $TR_4[$i+$k]); push (@VR_nr4, $VR_4[$n+$k]);push (@VR_nr4, $VR_4[$i+$k]);}}push (@TR_nr4, $TR_4[$k-4]);push (@VR_nr4, $VR_4[$k-4]);}
for (my $k=0; $k<5; $k++) {push (@TR_nr5, $TR_5[$k+1]); push (@VR_nr5, $VR_5[$k+1]); for (my $n=1; $n<scalar(@TR_5)-5; $n = $n+5) {my $i = $n + 5; if (($TR_5[$n+$k]!= $TR_5[$i+$k]-1) || ($VR_5[$n+$k]!= $VR_5[$i+$k]-1)){push (@TR_nr5, $TR_5[$n+$k]);push (@TR_nr5, $TR_5[$i+$k]); push (@VR_nr5, $VR_5[$n+$k]);push (@VR_nr5, $VR_5[$i+$k]);}}push (@TR_nr5, $TR_5[$k-5]);push (@VR_nr5, $VR_5[$k-5]);}
for (my $k=0; $k<6; $k++) {push (@TR_nr6, $TR_6[$k+1]); push (@VR_nr6, $VR_6[$k+1]); for (my $n=1; $n<scalar(@TR_6)-6; $n = $n+6) {my $i = $n + 6; if (($TR_6[$n+$k]!= $TR_6[$i+$k]-1) || ($VR_6[$n+$k]!= $VR_6[$i+$k]-1)){push (@TR_nr6, $TR_6[$n+$k]);push (@TR_nr6, $TR_6[$i+$k]); push (@VR_nr6, $VR_6[$n+$k]);push (@VR_nr6, $VR_6[$i+$k]);}}push (@TR_nr6, $TR_6[$k-6]);push (@VR_nr6, $VR_6[$k-6]);}
for (my $k=0; $k<7; $k++) {push (@TR_nr7, $TR_7[$k+1]); push (@VR_nr7, $VR_7[$k+1]); for (my $n=1; $n<scalar(@TR_7)-7; $n = $n+7) {my $i = $n + 7; if (($TR_7[$n+$k]!= $TR_7[$i+$k]-1) || ($VR_7[$n+$k]!= $VR_7[$i+$k]-1)){push (@TR_nr7, $TR_7[$n+$k]);push (@TR_nr7, $TR_7[$i+$k]); push (@VR_nr7, $VR_7[$n+$k]);push (@VR_nr7, $VR_7[$i+$k]);}}push (@TR_nr7, $TR_7[$k-7]);push (@VR_nr7, $VR_7[$k-7]);}
for (my $k=0; $k<8; $k++) {push (@TR_nr8, $TR_8[$k+1]); push (@VR_nr8, $VR_8[$k+1]); for (my $n=1; $n<scalar(@TR_8)-8; $n = $n+8) {my $i = $n + 8; if (($TR_8[$n+$k]!= $TR_8[$i+$k]-1) || ($VR_8[$n+$k]!= $VR_8[$i+$k]-1)){push (@TR_nr8, $TR_8[$n+$k]);push (@TR_nr8, $TR_8[$i+$k]); push (@VR_nr8, $VR_8[$n+$k]);push (@VR_nr8, $VR_8[$i+$k]);}}push (@TR_nr8, $TR_8[$k-8]);push (@VR_nr8, $VR_8[$k-8]);}
for (my $k=0; $k<9; $k++) {push (@TR_nr9, $TR_9[$k+1]); push (@VR_nr9, $VR_9[$k+1]); for (my $n=1; $n<scalar(@TR_9)-9; $n = $n+9) {my $i = $n + 9; if (($TR_9[$n+$k]!= $TR_9[$i+$k]-1) || ($VR_9[$n+$k]!= $VR_9[$i+$k]-1)){push (@TR_nr9, $TR_9[$n+$k]);push (@TR_nr9, $TR_9[$i+$k]); push (@VR_nr9, $VR_9[$n+$k]);push (@VR_nr9, $VR_9[$i+$k]);}}push (@TR_nr9, $TR_9[$k-9]);push (@VR_nr9, $VR_9[$k-9]);}
for (my $k=0; $k<10; $k++) {push (@TR_nr10, $TR_10[$k+1]); push (@VR_nr10, $VR_10[$k+1]); for (my $n=1; $n<scalar(@TR_10)-10; $n = $n+10) {my $i = $n + 10; if (($TR_10[$n+$k]!= $TR_10[$i+$k]-1) || ($VR_10[$n+$k]!= $VR_10[$i+$k]-1)){push (@TR_nr10, $TR_10[$n+$k]);push (@TR_nr10, $TR_10[$i+$k]); push (@VR_nr10, $VR_10[$n+$k]);push (@VR_nr10, $VR_10[$i+$k]);}}push (@TR_nr10, $TR_10[$k-10]);push (@VR_nr10, $VR_10[$k-10]);}
for (my $k=0; $k<11; $k++) {push (@TR_nr11, $TR_11[$k+1]); push (@VR_nr11, $VR_11[$k+1]); for (my $n=1; $n<scalar(@TR_11)-11; $n = $n+11) {my $i = $n + 11; if (($TR_11[$n+$k]!= $TR_11[$i+$k]-1) || ($VR_11[$n+$k]!= $VR_11[$i+$k]-1)){push (@TR_nr11, $TR_11[$n+$k]);push (@TR_nr11, $TR_11[$i+$k]); push (@VR_nr11, $VR_11[$n+$k]);push (@VR_nr11, $VR_11[$i+$k]);}}push (@TR_nr11, $TR_11[$k-11]);push (@VR_nr11, $VR_11[$k-11]);}
for (my $k=0; $k<12; $k++) {push (@TR_nr12, $TR_12[$k+1]); push (@VR_nr12, $VR_12[$k+1]); for (my $n=1; $n<scalar(@TR_12)-12; $n = $n+12) {my $i = $n + 12; if (($TR_12[$n+$k]!= $TR_12[$i+$k]-1) || ($VR_12[$n+$k]!= $VR_12[$i+$k]-1)){push (@TR_nr12, $TR_12[$n+$k]);push (@TR_nr12, $TR_12[$i+$k]); push (@VR_nr12, $VR_12[$n+$k]);push (@VR_nr12, $VR_12[$i+$k]);}}push (@TR_nr12, $TR_12[$k-12]);push (@VR_nr12, $VR_12[$k-12]);}
for (my $k=0; $k<13; $k++) {push (@TR_nr13, $TR_13[$k+1]); push (@VR_nr13, $VR_13[$k+1]); for (my $n=1; $n<scalar(@TR_13)-13; $n = $n+13) {my $i = $n + 13; if (($TR_13[$n+$k]!= $TR_13[$i+$k]-1) || ($VR_13[$n+$k]!= $VR_13[$i+$k]-1)){push (@TR_nr13, $TR_13[$n+$k]);push (@TR_nr13, $TR_13[$i+$k]); push (@VR_nr13, $VR_13[$n+$k]);push (@VR_nr13, $VR_13[$i+$k]);}}push (@TR_nr13, $TR_13[$k-13]);push (@VR_nr13, $VR_13[$k-13]);}
for (my $k=0; $k<14; $k++) {push (@TR_nr14, $TR_14[$k+1]); push (@VR_nr14, $VR_14[$k+1]); for (my $n=1; $n<scalar(@TR_14)-14; $n = $n+14) {my $i = $n + 14; if (($TR_14[$n+$k]!= $TR_14[$i+$k]-1) || ($VR_14[$n+$k]!= $VR_14[$i+$k]-1)){push (@TR_nr14, $TR_14[$n+$k]);push (@TR_nr14, $TR_14[$i+$k]); push (@VR_nr14, $VR_14[$n+$k]);push (@VR_nr14, $VR_14[$i+$k]);}}push (@TR_nr14, $TR_14[$k-14]);push (@VR_nr14, $VR_14[$k-14]);}
for (my $k=0; $k<15; $k++) {push (@TR_nr15, $TR_15[$k+1]); push (@VR_nr15, $VR_15[$k+1]); for (my $n=1; $n<scalar(@TR_15)-15; $n = $n+15) {my $i = $n + 15; if (($TR_15[$n+$k]!= $TR_15[$i+$k]-1) || ($VR_15[$n+$k]!= $VR_15[$i+$k]-1)){push (@TR_nr15, $TR_15[$n+$k]);push (@TR_nr15, $TR_15[$i+$k]); push (@VR_nr15, $VR_15[$n+$k]);push (@VR_nr15, $VR_15[$i+$k]);}}push (@TR_nr15, $TR_15[$k-15]);push (@VR_nr15, $VR_15[$k-15]);}
for (my $k=0; $k<16; $k++) {push (@TR_nr16, $TR_16[$k+1]); push (@VR_nr16, $VR_16[$k+1]); for (my $n=1; $n<scalar(@TR_16)-16; $n = $n+16) {my $i = $n + 16; if (($TR_16[$n+$k]!= $TR_16[$i+$k]-1) || ($VR_16[$n+$k]!= $VR_16[$i+$k]-1)){push (@TR_nr16, $TR_16[$n+$k]);push (@TR_nr16, $TR_16[$i+$k]); push (@VR_nr16, $VR_16[$n+$k]);push (@VR_nr16, $VR_16[$i+$k]);}}push (@TR_nr16, $TR_16[$k-16]);push (@VR_nr16, $VR_16[$k-16]);}
for (my $k=0; $k<17; $k++) {push (@TR_nr17, $TR_17[$k+1]); push (@VR_nr17, $VR_17[$k+1]); for (my $n=1; $n<scalar(@TR_17)-17; $n = $n+17) {my $i = $n + 17; if (($TR_17[$n+$k]!= $TR_17[$i+$k]-1) || ($VR_17[$n+$k]!= $VR_17[$i+$k]-1)){push (@TR_nr17, $TR_17[$n+$k]);push (@TR_nr17, $TR_17[$i+$k]); push (@VR_nr17, $VR_17[$n+$k]);push (@VR_nr17, $VR_17[$i+$k]);}}push (@TR_nr17, $TR_17[$k-17]);push (@VR_nr17, $VR_17[$k-17]);}
for (my $k=0; $k<18; $k++) {push (@TR_nr18, $TR_18[$k+1]); push (@VR_nr18, $VR_18[$k+1]); for (my $n=1; $n<scalar(@TR_18)-18; $n = $n+18) {my $i = $n + 18; if (($TR_18[$n+$k]!= $TR_18[$i+$k]-1) || ($VR_18[$n+$k]!= $VR_18[$i+$k]-1)){push (@TR_nr18, $TR_18[$n+$k]);push (@TR_nr18, $TR_18[$i+$k]); push (@VR_nr18, $VR_18[$n+$k]);push (@VR_nr18, $VR_18[$i+$k]);}}push (@TR_nr18, $TR_18[$k-18]);push (@VR_nr18, $VR_18[$k-18]);}
for (my $k=0; $k<19; $k++) {push (@TR_nr19, $TR_19[$k+1]); push (@VR_nr19, $VR_19[$k+1]); for (my $n=1; $n<scalar(@TR_19)-19; $n = $n+19) {my $i = $n + 19; if (($TR_19[$n+$k]!= $TR_19[$i+$k]-1) || ($VR_19[$n+$k]!= $VR_19[$i+$k]-1)){push (@TR_nr19, $TR_19[$n+$k]);push (@TR_nr19, $TR_19[$i+$k]); push (@VR_nr19, $VR_19[$n+$k]);push (@VR_nr19, $VR_19[$i+$k]);}}push (@TR_nr19, $TR_19[$k-19]);push (@VR_nr19, $VR_19[$k-19]);}
for (my $k=0; $k<20; $k++) {push (@TR_nr20, $TR_20[$k+1]); push (@VR_nr20, $VR_20[$k+1]); for (my $n=1; $n<scalar(@TR_20)-20; $n = $n+20) {my $i = $n + 20; if (($TR_20[$n+$k]!= $TR_20[$i+$k]-1) || ($VR_20[$n+$k]!= $VR_20[$i+$k]-1)){push (@TR_nr20, $TR_20[$n+$k]);push (@TR_nr20, $TR_20[$i+$k]); push (@VR_nr20, $VR_20[$n+$k]);push (@VR_nr20, $VR_20[$i+$k]);}}push (@TR_nr20, $TR_20[$k-20]);push (@VR_nr20, $VR_20[$k-20]);}

# two arrays (one for TR and one for VR) with the first position and the last positions for all repeats
my  @all_TR_nr  = "";
my @all_VR_nr = "";

# to add all first and last positions for successive positions of all repeats in one array
# positions for TR in @all_TR_nr and positions for VR in @all_VR_nr
if (3 <= $sca1) { shift @TR_nr1; push (@all_TR_nr , @TR_nr1); shift @VR_nr1; push (@all_VR_nr , @VR_nr1); }
if (3 <= $sca2) { shift @TR_nr2; push (@all_TR_nr , @TR_nr2); shift @VR_nr2; push (@all_VR_nr , @VR_nr2); }
if (3 <= $sca3) { shift @TR_nr3; push (@all_TR_nr , @TR_nr3); shift @VR_nr3; push (@all_VR_nr , @VR_nr3); }
if (3 <= $sca4) { shift @TR_nr4; push (@all_TR_nr , @TR_nr4); shift @VR_nr4; push (@all_VR_nr , @VR_nr4); }
if (3 <= $sca5) { shift @TR_nr5; push (@all_TR_nr , @TR_nr5); shift @VR_nr5; push (@all_VR_nr , @VR_nr5); }
if (3 <= $sca6) { shift @TR_nr6; push (@all_TR_nr , @TR_nr6); shift @VR_nr6; push (@all_VR_nr , @VR_nr6); }
if (3 <= $sca7) { shift @TR_nr7; push (@all_TR_nr , @TR_nr7); shift @VR_nr7; push (@all_VR_nr , @VR_nr7); }
if (3 <= $sca8) { shift @TR_nr8; push (@all_TR_nr , @TR_nr8); shift @VR_nr8; push (@all_VR_nr , @VR_nr8); }
if (3 <= $sca9) { shift @TR_nr9; push (@all_TR_nr , @TR_nr9); shift @VR_nr9; push (@all_VR_nr , @VR_nr9); }
if (3 <= $sca10) { shift @TR_nr10; push (@all_TR_nr , @TR_nr10); shift @VR_nr10; push (@all_VR_nr , @VR_nr10); }
if (3 <= $sca11) { shift @TR_nr11; push (@all_TR_nr , @TR_nr11); shift @VR_nr11; push (@all_VR_nr , @VR_nr11); }
if (3 <= $sca12) { shift @TR_nr12; push (@all_TR_nr , @TR_nr12); shift @VR_nr12; push (@all_VR_nr , @VR_nr12); }
if (3 <= $sca13) { shift @TR_nr13; push (@all_TR_nr , @TR_nr13); shift @VR_nr13; push (@all_VR_nr , @VR_nr13); }
if (3 <= $sca14) { shift @TR_nr14; push (@all_TR_nr , @TR_nr14); shift @VR_nr14; push (@all_VR_nr , @VR_nr14); }
if (3 <= $sca15) { shift @TR_nr15; push (@all_TR_nr , @TR_nr15); shift @VR_nr15; push (@all_VR_nr , @VR_nr15); }
if (3 <= $sca16) { shift @TR_nr16; push (@all_TR_nr , @TR_nr16); shift @VR_nr16; push (@all_VR_nr , @VR_nr16); }
if (3 <= $sca17) { shift @TR_nr17; push (@all_TR_nr , @TR_nr17); shift @VR_nr17; push (@all_VR_nr , @VR_nr17); }
if (3 <= $sca18) { shift @TR_nr18; push (@all_TR_nr , @TR_nr18); shift @VR_nr18; push (@all_VR_nr , @VR_nr18); }
if (3 <= $sca19) { shift @TR_nr19; push (@all_TR_nr , @TR_nr19); shift @VR_nr19; push (@all_VR_nr , @VR_nr19); }
if (3 <= $sca20) { shift @TR_nr20; push (@all_TR_nr , @TR_nr20); shift @VR_nr20; push (@all_VR_nr , @VR_nr20); }

shift @all_TR_nr;
shift @all_VR_nr;

my $n;
# after the assembly of all positions for all repeats, the positions are scattered
# in this loop the ruptured positions will be connected with each other
MYLOOP2: for ($n=0; $n< @all_TR_nr;$n = $n+2)  {
         for (my $i=0; $i<@all_TR_nr;$i= $i+2) {
             if ($all_TR_nr[$n+1] == $all_TR_nr[$i]-1) {
                if ($all_VR_nr[$n+1] == $all_VR_nr[$i]-1){
                splice (@all_TR_nr, $i, 1, $all_TR_nr[$n]); splice (@all_TR_nr, $n, 2);
                splice (@all_VR_nr, $i, 1, $all_VR_nr[$n]); splice (@all_VR_nr, $n, 2);
                $n=0;
                next MYLOOP2
                }
             }
             
             elsif( ($all_TR_nr[$i+1] == $all_TR_nr[$n]-1)) {
                    if ($all_VR_nr[$i+1] == $all_VR_nr[$n]-1) {
                    splice (@all_TR_nr, $i+1, 1, $all_TR_nr[$n+1]); splice (@all_TR_nr, $n, 2);
                    splice (@all_VR_nr, $i+1, 1, $all_VR_nr[$n+1]); splice (@all_VR_nr, $n, 2);
                    $n=0;
                    next MYLOOP2
                    }
             }
         }
}

# number of elements in the array with final positions
my $scaTRnr =scalar(@all_TR_nr);

  for (my $n=1; $n<= $scaTRnr/2; $n++) {

                # the exact length of the repeat
                my $repeatlen = $all_TR_nr[1] - $all_TR_nr[0]+50;
                my $allTRnr50 = $all_TR_nr[1]+49;
                my $allVRnr50 = $all_VR_nr[1]+49;

                my $TRseq = substr($genome, $all_TR_nr[0],$repeatlen);
                my $VRseq = substr($genome, $all_VR_nr[0], $repeatlen);
                my $TR_postoRT = $all_TR_nr[0] - $start;
                my $VR_postoRT = $all_VR_nr[0] - $start;

        ## to calculate number of each base in DNA sequence
        ## in order to calculate number of subsituted base in VR

        # for TR
            my  $TRseqobj = Bio::PrimarySeq->new(-seq      => $TRseq,
                                         -alphabet => 'dna',
                                         -id       => 'test');
            my $TRseq_stats  =  Bio::Tools::SeqStats->new(-seq => $TRseqobj);

          # obtain a hash of counts of each type of monomer
          # (i.e. amino or nucleic acid)
          $TRseq_stats  =  Bio::Tools::SeqStats->new(-seq =>$TRseqobj);
          my $TR_hash_ref = $TRseq_stats->count_monomers();  # e.g. for DNA sequence

        # for VR
           my  $VRseqobj = Bio::PrimarySeq->new(-seq      => $VRseq,
                                         -alphabet => 'dna',
                                         -id       => 'test');
            my $VRseq_stats  =  Bio::Tools::SeqStats->new(-seq => $VRseqobj);

          # obtain a hash of counts of each type of monomer
          # (i.e. amino or nucleic acid)
          $VRseq_stats  =  Bio::Tools::SeqStats->new(-seq =>$VRseqobj);
          my $VR_hash_ref = $VRseq_stats->count_monomers();  # e.g. for DNA sequence

        # number of bases (A, C, G, and T) in TR and VR
        # N if genome contains nucleotides marked as N (non normal bases A, C, G, and T)
        my $TR_A = 0;
        my $TR_C = 0;
        my $TR_G = 0;
        my $TR_T = 0;
        my $TR_N = 0;
        my $VR_A = 0;
        my $VR_C = 0;
        my $VR_G = 0;
        my $VR_T = 0;
        my $VR_N = 0;
        my $TR_b = 0;
        my $VR_b = 0;

        # number of substituted bases A (C, G or T) in VR
        my $b_subs;

        foreach my $base (sort keys %$TR_hash_ref) {
        if ($base eq $b){$b_subs = ($TR_hash_ref->{$base}) - ($VR_hash_ref->{$base}); $TR_b = $TR_hash_ref->{$base}; $VR_b = $VR_hash_ref->{$base};}
#        if ($base eq 'A'){$A_subs = ($TR_hash_ref->{$base}) - ($VR_hash_ref->{$base});  $TR_A = $TR_hash_ref->{$base}; $VR_A = $VR_hash_ref->{$base};}
        if ($base eq 'A'){$TR_A = $TR_hash_ref->{$base}; $VR_A = $VR_hash_ref->{$base};}
        if ($base eq 'C'){$TR_C = $TR_hash_ref->{$base}; $VR_C = $VR_hash_ref->{$base};}
        if ($base eq 'G'){$TR_G = $TR_hash_ref->{$base}; $VR_G = $VR_hash_ref->{$base};}
        if ($base eq 'T'){$TR_T = $TR_hash_ref->{$base}; $VR_T = $VR_hash_ref->{$base};}
        if ($base eq 'N'){$TR_N = $TR_hash_ref->{$base}; $VR_N = $VR_hash_ref->{$base};}
        }

        if ($basenumb < $TR_b){
           if ($subs <= $b_subs){
              if ($TR_N == 0){
              print OUTFILE ">TR$n/$all_TR_nr[0]--$allTRnr50/\n$TRseq\t\tA: $TR_A\tC: $TR_C\tG: $TR_G\tT: $TR_T\n>VR$n/$all_VR_nr[0]--$allVRnr50/\n$VRseq\t\tA: $VR_A\tC: $VR_C\tG: $VR_G\tT: $VR_T\nnumber of substituted base $b: $b_subs\nposition of RT relative to TR is $TR_postoRT\nposition of RT relative to VR is $VR_postoRT\n\n";
              }
           }
        }

        shift(@all_TR_nr);
        shift(@all_TR_nr);
        shift(@all_VR_nr);
        shift(@all_VR_nr);

 }
}
}
