#!/bin/bash

if [ 1 == 2 ]  ###code annotation start
then

fi    ###code annotation end

###BLASTN result
grep -v "#" chr21-anoCar2.blastn |awk '{print $1"\t"$7"\t"$8}' |sort -k1,1 -k2n,2 |uniq >chr21-anoCar2.blastn.bed
./mergeBed.pl chr21-anoCar2.blastn.bed chr21-anoCar2.blastn.merged.bed

###LASTZ result
./../src/axt2cov.pl chr21-anoCar2.lastz.cov chr21-anoCar2.lastz
awk '{print $1"\t"$2"\t"$3}' chr21-anoCar2.lastz.cov |sort -k1,1 -k2n,2 |uniq chr21-anoCar2.lastz.bed
./mergeBed.pl chr21-anoCar2.lastz.bed chr21-anoCar2.lastz.merged.bed

###compare length distribution, header: length   method
grep -v "#" chr21-anoCar2.blastn |awk '{if($8>$7) print $8-$7"\tBLASTN"; else print $7-$8"\tBLASTN"}' >len.txt
awk '{print $3-$2"\tLASTZ"}' chr21-anoCar2.lastz.bed >>len.txt

###compare iedntity distribution, header: identity   method
awk '{print $9"\tLASTZ"}' chr21-anoCar2.lastz.cov >identity.txt
grep -v "#" chr21-anoCar2.blastn |awk '{print $3/100"\tBLASTN"}' >>identity.txt


