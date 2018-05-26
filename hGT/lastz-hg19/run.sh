#!/bin/bash

if [ 1 == 2 ]  ###code annotation start
then

###############
# iden60len40 #
###############

for i in `cat 53species.id`
do
    ./../axt2cov.pl cov/$i.cov /share/home/user/fzyan/hGT/data/data-wzhuang/vs$i/*.net.axt  #nohup 
    cat cov/$i.cov |sort -k1,1 -k2n,2 >cov/$i-sort.cov #nohup 
    rm cov/$i.cov
    
    awk '{if($9>=0.6){print $1"\t"$2"\t"$3}}' cov/$i-sort.cov >iden60/$i.bed
    ~/hGT/src/mergeBed.pl iden60/$id.bed iden60/$id-merge.bed
    mv iden60/$id-merge.bed iden60/$id.bed
done

fi             ###code annotation end

for i in `cat 12nonmammal.id`
do
    cp iden60/$i.bed iden60/nonmammal/$i.bed
done

chr=(chr1 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr2 chr20 chr21 chr22 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chrX chrY)
for i in ${chr[@]}
do
    ./merge-nonmammal.pl chr_len.txt $i tmp-$i 500 iden60/nonmammal/*bed
done

cat tmp-* |sort -k1,1 -k2n,2 >iden60/nonmammal/merge-cov2-500bp.bed
rm tmp-*

for id in `cat 41mammal.id`
do
    ./../src/merge-mammal.pl iden60/$id.bed iden60/mammal/$id-merged.txt
    
    nohup ./../src/screenHGT.pl iden60/nonmammal/merge-cov2-500bp.bed tmp-$id 0.4 iden60/mammal/$id-merged.txt &
done

./summaryMammal.pl iden60/nonmammal/merge-cov2-500bp.bed  screenHGT.out tmp-*
rm tmp* 
