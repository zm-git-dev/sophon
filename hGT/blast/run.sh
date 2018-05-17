#!/bin/bash

if [ 1 == 2 ]  ###code annotation start
then

# BLASTN hits ----> bed format (sorted, merged)
for i in `cat 51species.id`
do
    nohup cat alignment/seg30M-$i.* |grep -v "#" |awk '{if($8>$7) print $1"\t"$7"\t"$8; else print $1"\t"$8"\t"$7}' |sort -k1,1 -k2n,2 |uniq >bed/$i.bed
    ~/hGT/compare2lastz/mergeBed.pl bed/$i.bed mergeBed/$i.bed
done

for i in `cat 12nonmammal.id`
do
    cp mergeBed/$i.bed mergeBed/nonmammal/$i.bed
done
~/hGT/src/merge-nonmammal.pl ~/hGT/segment/hg19-seg1k-step1k-4mer-pass.fa 500 mergeBed/nonmammal/merge-cov2-500bp.bed mergeBed/nonmammal/GC*bed

fi    ###code annotation end

for i in `cat 39mammal.id`
do
    nohup ~/hGT/compare2lastz/mergeBed.pl bed/$i.bed mergeBed/$i.bed &
    ~/hGT/src/merge-mammal.pl mergeBed/$i.bed mergeBed/mammal/$i-merged.txt
done

~/hGT/src/screenHGT.pl mergeBed/nonmammal/merge-cov2-500bp.bed screenHGT-len0.4.out 0.4 mergeBed/mammal/*merged.txt
awk '{if($4<=8){print $0}}' screenHGT-len0.4.out |awk -F '[\t|-]' '{print $1"\t"$2+$4"\t"$3+$5}' |tr 'A-Z' 'a-z' >screenHGT-len0.4-8mammals.bed
