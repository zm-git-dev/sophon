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


awk '{if($4<=8) print $0}' screenHGT.out |sort -k1,1 -k2n,2 >screenHGT-8mammals.bed
~/hGT/src/getHGTseq.pl  ~/hGT/data/hg19/hg19-UCSC.fa screenHGT-8mammals.bed screenHGT-8mammals.fa
 blastn -task blastn -query screenHGT-8mammals.fa -db ~/hGT/db/hg19 -out screenHGT-8mammals-hg19.blastn -evalue 1e-3 -num_threads 32 -outfmt 7 -word_size 9
./../blast/filterHits.pl screenHGT-8mammals-hg19.blastn


for i in hit/*.txt
do
    echo $i
    pre=${i%.txt}
    suf=${pre#hit/}
    awk '{if($4>=90) print $0}' $i >hit-iden90/$suf.txt

    cat $i |sort -k1,1 -k2n,2 >$pre.sort.txt
    ~/hGT/src/mergeBed.pl $pre.sort.txt $pre.merge.txt
    rm $pre.sort.txt
    
    cat hit-iden90/$suf.txt |sort -k1,1 -k2n,2 >hit-iden90/$suf.sort.txt
    ~/hGT/compare2lastz/mergeBed.pl hit-iden90/$suf.sort.txt hit-iden90/$suf.merge.txt
    rm hit-iden90/$suf.sort.txt
done

fi             ###code annotation end

for id in `grep ">" screenHGT-8mammals.fa |tr -d ">"`
do
    num=$(cat hit/$id.txt |wc -l)
    avg_len=$(awk '{print $3-$2+1}' hit/$id.txt |awk '{sum+=$1} END {print "",sum/NR}')
    avg_iden=$(awk '{print $4}' hit/$id.txt |awk '{sum+=$1} END {print "",sum/NR}')
    merge_num=$(cat hit/$id.merge.txt |wc -l)
    cov_len=$(awk '{print $3-$2+1}' hit/$id.merge.txt |awk '{sum+=$1} END {print "",sum}')
    echo -e "$id\t$num\t$avg_len\t$avg_iden\t$merge_num\t$cov_len" >>summaryHit-tmp.txt

    num=$(cat hit-iden90/$id.txt |wc -l)
    avg_len=$(awk '{print $3-$2+1}' hit-iden90/$id.txt |awk '{sum+=$1} END {print "",sum/NR}')
    avg_iden=$(awk '{print $4}' hit-iden90/$id.txt |awk '{sum+=$1} END {print "",sum/NR}')
    merge_num=$(cat hit-iden90/$id.merge.txt |wc -l)
    cov_len=$(awk '{print $3-$2+1}' hit-iden90/$id.merge.txt |awk '{sum+=$1} END {print "",sum}')
    echo -e "$id\t$num\t$avg_len\t$avg_iden\t$merge_num\t$cov_len" >>summaryHit-iden90-tmp.txt
done

echo -e "id\thit_num\tavg_len\tavg_iden\tmerge_hit_num\tcov_len" >>summaryHit.txt
echo -e "id\thit_num\tavg_len\tavg_iden\tmerge_hit_num\tcov_len" >>summaryHit-iden90.txt

awk '{if($2==0) print $1"\t0\t0\t0\t0\t0"; else print $0}' summaryHit-tmp.txt | sort -rnk 2 >>summaryHit.txt
awk '{if($2==0) print $1"\t0\t0\t0\t0\t0"; else print $0}' summaryHit-iden90-tmp.txt | sort -rnk 2 >>summaryHit-iden90.txt
rm summaryHit-tmp.txt summaryHit-iden90-tmp.txt




~/hGT/src/biodiff.pl ~/hGT/data/hg19/gencode.v19.geneinfo.bed screenHGT-8mammals.bed 59hgt2gene.txt
~/hGT/src/biodiff.pl ~/hGT/data/hg19/rmsk-merge.bed screenHGT-8mammals.bed 59hgt2repeat.txt

./repeatDistribution.pl summaryHit-iden90.txt 59hgt2repeat.txt plot3.txt
grep -v region plot3.txt |grep -v "\s0.000$"  |awk '{print $1}' |uniq >level3.txt


