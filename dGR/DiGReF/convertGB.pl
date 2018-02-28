# convertGB v1 - Program to write output from DiGReF in a GenBank format - 26. April 2012
# Written by Mohamed Lisfi, Department of Genetics, University of Kaiserslautern,
# Postfach 3049, 67653 Kaiserslautern, Germany.
# Email contact: cullum@rhrk.uni-kl.de

use strict;
use warnings;

#*****************************************************************************
#***          USING THE PROGRAM WITH DEFAULT PARAMETERS                    ***
#
# The program needs a list of GI numbers one to a line in the file GI.txt
# it also needs the output files from DiGReF for these GI numbers, which
# have names <GI number>.txt
# The output files have names <GI number>.gb and can be viewed by programs
# such as Artemis
#
#*****************************************************************************
#***     IF YOU CHANGED THE LENGTH OF DNA SEARCHED IN DiGReF               ***
# You must also change the length parameter in convertGB

# the length of sequence up- and downstream of RT
my $seqlen = 5000; # length in bp

#*****************************************************************************


# file with a list of GI Numbers
open (INFILE2,"GI.txt") or die "Opening input file failed2: $!\n";
my @Inlines2 = <INFILE2>;




for (my $i = 0; $i < @Inlines2; $i++){

chomp $Inlines2[$i];

# files with results of DiGReF program
open (INFILE,"$Inlines2[$i].txt") or die "Opening input file failed1: $!\n";

open (OUT,">$Inlines2[$i].gb") or die "Opening output file failed: $!\n";


my @Inlines =<INFILE>;

my $start;
my $RT_start;
my $RT_end;
my $TR_start;
my $TR_end;
my $VR_start;
my $VR_end;

   # to read the data when the RT is in forward
    if ($Inlines[0] =~m/^RT (\d+)\.\.(\d+)\s*\w*\s*\w*\s*\w*\W*\s*(\d*)/) {
    
            for (my $j = $seqlen ; 0 <=$j;  $j--) { # $j is used because sometimes the TR is localized at the beginning, in a position less than "$seqlen" bases

                  $start = $1 - $j;
                  if (0 <= $start ){ 

                  $RT_start = $1 - $start;
                  $RT_end = $2 - $start + 2;

                   printf OUT ("%-5s", "FT");
                   printf OUT ("%-16s", "CDS");
                   print OUT "$RT_start..$RT_end\n";
                   printf OUT ("%-21s", "FT");
                   print OUT "/note=\"RT\"\n";
                   printf OUT ("%-21s", "FT");
                   print OUT "/color=9\n";

                   printf OUT ("%-5s", "FT");
                   printf OUT ("%-16s", "RT");
                   print OUT "$RT_start..$RT_end\n";
                   printf OUT ("%-21s", "FT");
                   print OUT "/note=\"RT\"\n";
                   printf OUT ("%-21s", "FT");
                   print OUT "/color=9\n";

                           for (my $i=1; $i<@Inlines; $i++) {

                            # to read the coordinates of TR
                                   if  ($Inlines[$i] =~m/^>TR(\d*)\W{1}(\d+)--(\d+)\W{1}\s*/) {

                                 $TR_start = $2-$start+1;
                                 $TR_end = $3-$start+3;

                                 # to print coordinates of TR
                                   printf OUT ("%-5s", "FT");
                                   printf OUT ("%-16s", "TR$1");
                                   print OUT "$TR_start..$TR_end\n";
                                   printf OUT ("%-21s", "FT");
                                   print OUT "/note=\"TR$1\"\n";
                                   printf OUT ("%-21s", "FT");
                                   print OUT "/color=3\n";
                                   }

                                # to read the data of VR
                                   elsif ($Inlines[$i] =~m/^>VR(\d*)\W{1}(\d+)--(\d+)\W{1}\s*/) {

                                    $VR_start = $2-$start+1;
                                    $VR_end = $3-$start+3;
                                    
                                    # to print coordinates of VR
                                    printf OUT ("%-5s", "FT");
                                    printf OUT ("%-16s", "VR$1");
                                    print OUT "$VR_start..$VR_end\n";
                                    printf OUT ("%-21s", "FT");
                                    print OUT "/note=\"VR$1\"\n";
                                    printf OUT ("%-21s", "FT");
                                    print OUT "/color=2\n";
                                    }
                           }
                 last
                 }
           }
   }

   # to read the data when the RT is in copmlement
   elsif ($Inlines[0] =~m/^RT complement\W*(\d+)\.\.(\d+)\W*\s*\w*\s*\w*\s*\w*\W*\s*(\d*)/) {
   
  my $RTcomplStart;
  my $TRcomplStart;
  my $VRcomplStart;
  my $len;
  my $TR_len;
  my $VR_len;
  my $RTpos;
  my $TRpos;
   
   $RTpos =$1;
   
          # $j is used because sometimes the TR is localized at the extremity of complement, in a position less than the value "$seqlen"
           for (my $j = $seqlen ; 0  <=$j;  $j--) { 
           $RTcomplStart = $3-$1;

           $start = $RTcomplStart - $j;
           $len = $2-$1;
           $RT_start = $RTcomplStart-$start;
           $RT_end = $j + $len - 3;

                  if (0 <=$start) { #

                  # to print coordinates of RT
                   printf OUT ("%-5s", "FT");
                   printf OUT ("%-16s", "CDS");
                   print OUT "$RT_start..$RT_end\n";
                   printf OUT ("%-21s", "FT");
                   print OUT "/note=\"RT\"\n";
                   printf OUT ("%-21s", "FT");
                   print OUT "/color=9\n";

                   printf OUT ("%-5s", "FT");
                   printf OUT ("%-16s", "RT");
                   print OUT "$RT_start..$RT_end\n";
                   printf OUT ("%-21s", "FT");
                   print OUT "/note=\"RT\"\n";
                   printf OUT ("%-21s", "FT");
                   print OUT "/color=9\n";

                           for (my $i=0; $i<@Inlines; $i++) {
                           
                                   # for TR
                                   if  ($Inlines[$i] =~m/^>TR(\d*)\W{1}(\d+)--(\d+)\W{1}\s*/) {

                                   $TRpos =$2;
                                           if ($RTcomplStart < $TRpos) {

                                            $TRcomplStart =   $2-$RTcomplStart;
                                            $TR_start =$TRcomplStart + $j + $len;
                                            $TR_len = $3-$2;
                                            $TR_end = $TR_start +$TR_len;

                                            # to print coordinates of TR
                                           printf OUT ("%-5s", "FT");
                                           printf OUT ("%-16s", "TR$1");
                                           print OUT "$TR_start.. $TR_end\n";
                                           printf OUT ("%-21s", "FT");
                                           print OUT "/note=\"TR$1\"\n";
                                           printf OUT ("%-21s", "FT");
                                           print OUT "/color=3\n";
                                           }
                                           
                                           elsif ($TRpos < $RTcomplStart) {
                                                   $TRcomplStart = $2 - $RTcomplStart ;
                                                   $TR_start = $TRcomplStart + $j + $len;
                                                   $TR_len = $3-$2;
                                                   $TR_end = $TR_start +$TR_len;

                                            # to print coordinates of TR
                                           printf OUT ("%-5s", "FT");
                                           printf OUT ("%-16s", "TR$1");
                                           print OUT "$TR_start.. $TR_end\n";
                                           printf OUT ("%-21s", "FT");
                                           print OUT "/note=\"TR$1\"\n";
                                           printf OUT ("%-21s", "FT");
                                           print OUT "/color=3\n";
                                           }
                                   }

                                   # for VR
                                   elsif ($Inlines[$i] =~m/^>VR(\d*)\W{1}(\d+)--(\d+)\W{1}\s*/) {
                                   
                                         if ($RTcomplStart < $TRpos) {
                                         
                                         $VRcomplStart = $2 - $RTcomplStart;
                                         $VR_start = $VRcomplStart + $j + $len;
                                         $VR_len = $3-$2;
                                         $VR_end = $VR_start +$VR_len;

                                           # to print coordinates of VR
                                          printf OUT ("%-5s", "FT");
                                          printf OUT ("%-16s", "VR$1");
                                          print OUT "$VR_start..$VR_end\n";
                                          printf OUT ("%-21s", "FT");
                                          print OUT "/note=\"VR$1\"\n";
                                          printf OUT ("%-21s", "FT");
                                          print OUT "/color=2\n";
                                          }

                                          elsif ($TRpos < $RTcomplStart) {
                                          
                                          $VRcomplStart = $2 - $RTcomplStart ;
                                          $VR_start = $VRcomplStart + $j + $len;
                                          $VR_len = $3-$2;
                                          $VR_end = $VR_start +$VR_len;

                                            # to print coordinates of VR
                                           printf OUT ("%-5s", "FT");
                                           printf OUT ("%-16s", "VR$1");
                                           print OUT "$VR_start..$VR_end\n";
                                           printf OUT ("%-21s", "FT");
                                           print OUT "/note=\"VR$1\"\n";
                                           printf OUT ("%-21s", "FT");
                                           print OUT "/color=2\n";
                                           }
                                   }

                        }
                last
                }
        }
  }

print OUT ">$Inlines2[$i]\n";

# to print DNA sequence
print OUT "$Inlines[3]";
next
}
