#!/usr/bin/bash

###To get the database
#./getDatabase.pl all-intact.gtf all-intact-partialConfirmed.fa

###To get the DGR cassetes
#awk '{if($2=="VR") print $1"\t"$6"\t"$7"\t"$3"\t"$2 ; else print $1"\t"$4"\t"$5"\t"$3"\t"$2}' all-intact.gtf |sort |uniq |sort -rk1,1 -k2n,2 -k2n,2 >structure1.txt
#./transStructure.pl structure1.txt structure2.txt

#merge information
#./mergeInfo.pl DGR.txt structure2.txt sample.info DGR2.txt

#count the DGR cassetes
#./countStructure.pl structure2.txt |sort -rnk 2 >structure_count.txt


#get the core DGRs
grep "\sRT\s" all-intact.gtf |awk '{print ">"$1"\n"$6}' >all-intact-RT.fa
cd-hit-est -i all-intact-RT.fa -c 0.9 -o all-intact-RT-cdhit0.9.fa
grep ">" all-intact-RT-cdhit0.9.fa |tr -d ">" >core.id
./getCoreGTF.pl all-intact.gtf core.id core.gtf
