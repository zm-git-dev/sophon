#!/bin/bash

if [ 1 == 2 ]  ###code annotation start
then

## axt format to bed format (sort and merge)
for id in `cat 51species.id`
do
    ~/hGT/src/axt2cov.pl cov/$id.cov axt/$id.axt  #nohup
    awk '{if($9>=0.6) print $1"\t"$2"\t"$3}' cov/$id.cov |sort -k1,1 -k2n,2 >iden60/$id.bed #nohup
    ~/hGT/src/mergeBed.pl iden60/$id.bed iden60/$id-merge.bed
    mv iden60/$id-merge.bed iden60/$id.bed
done


for i in `cat 12nonmammal.id`
do
    cp iden60/$i.bed iden60/nonmammal/$i.bed
done

for id in `cat 39mammal.id`
do
    ./../src/merge-mammal.pl iden60/$id.bed iden60/mammal/$id-merge.txt
done

fi             ###code annotation end

~/hGT/src/merge-nonmammal.pl ~/hGT/segment/hg19-seg1k-step1k-4mer-pass.fa 500 iden60/nonmammal/merge-cov2-500bp.bed iden60/nonmammal/*bed

~/hGT/src/screenHGT.pl iden60/nonmammal/merge-cov2-500bp.bed screenHGT-len0.4.out 0.4 iden60/mammal/*merge.txt
# delete "iden60/mammal/" and "_genomic-merge.txt" in the file, then get the real name
./../blast/getName.pl screenHGT.out ~/hGT/data/53genome/info.txt mm
mv mm screenHGT.out

## filter : <= 8 mammals
## replace: CHR -> chr; UN -> Un; GL -> gl
awk '{if($4<=8) print $1"-"$2"-"$3}' screenHGT.out |awk -F '-' '{print $1"\t"$2+$4-1"\t"$2+$5-1}' |sort -k1,1 -k2n,2 >screenHGT-8mammals.bed
## merge the HGTs if overlap
~/hGT/src/mergeBed.pl screenHGT-8mammals.bed screenHGT-8mammals-merge.bed
