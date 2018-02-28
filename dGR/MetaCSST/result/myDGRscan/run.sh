#!/usr/bin/bash

for i in *out
do

#./myDGRscan.pl HMASM_putative_MetaCSST.fa 40 A A.out
#awk '{sum+=$5;count+=1} END{print "avg:\t"sum/count}' A.out

echo $i
awk '{print $6}' $i >mm
length mm

done
exit


