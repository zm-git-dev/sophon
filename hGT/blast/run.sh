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

for i in `cat 39mammal.id`
do
    nohup ~/hGT/compare2lastz/mergeBed.pl bed/$i.bed mergeBed/$i.bed &
    ~/hGT/src/merge-mammal.pl mergeBed/$i.bed mergeBed/mammal/$i-merged.txt
done

~/hGT/src/screenHGT.pl mergeBed/nonmammal/merge-cov2-500bp.bed screenHGT.out 0.4 mergeBed/mammal/*merged.txt
./getName.pl screenHGT.out ~/hGT/data/53genome/info.txt mm
mv mm screenHGT.out
### replace: CHR -> chr; chrUN -> chrUn; GL -> gl

awk '{if($4<=8){print $0}}' screenHGT.out |awk -F '[\t|-]' '{print $1"\t"$2+$4-1"\t"$2+$5-1"\t"$6"\t"$7}' |sort -k1,1 -k2n,2 >screenHGT-8mammals.bed
~/hGT/src/getHGTseq.pl ~/hGT/data/hg19/hg19-UCSC.fa screenHGT-8mammals.bed screenHGT-8mammals.fa

blastn -task blastn -query screenHGT-8mammals.fa -db ~/hGT/db/hg19 -out screenHGT-8mammals-hg19.blastn -evalue 1e-3 -num_threads 20 -outfmt 7 -word_size 9

### split the hits according to the query sequence, to different files
./filterHits.pl screenHGT-8mammals-hg19.blastn

for i in hit/*.txt
do
    pre=${i%.txt}
    suf=${pre#hit/}
    awk '{if($4>=90) print $0}' $i >hit-iden90/$suf.txt

    cat $i |sort -k1,1 -k2n,2 >$pre.sort.txt
    ~/hGT/compare2lastz/mergeBed.pl $pre.sort.txt $pre.merge.txt
    rm $pre.sort.txt
    
    cat hit-iden90/$suf.txt |sort -k1,1 -k2n,2 >hit-iden90/$suf.sort.txt
    ~/hGT/compare2lastz/mergeBed.pl hit-iden90/$suf.sort.txt hit-iden90/$suf.merge.txt
    rm hit-iden90/$suf.sort.txt
done

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


fi    ###code annotation end


# multi-alignment
muscle -in screenHGT-8mammals.fa -out screenHGT-8mammals.fa.mucle
# build the phylogenetic tree
FastTreeMP -nt screenHGT-8mammals.fa.mucle >screenHGT-8mammals.fa.mucle.tree

~/hGT/src/biodiff.pl ~/hGT/data/hg19/gencode.v19.geneinfo.bed screenHGT-8mammals.bed 474hgt2gene.txt
~/hGT/src/biodiff.pl ~/hGT/data/hg19/rmsk-merge.bed screenHGT-8mammals.bed 474hgt2repeat.txt

 ./repeatDistribution.pl summaryHit-iden90.txt 474hgt2repeat.txt plot1.txt
grep -v region plot1.txt |awk '{print $1}' |uniq >level.txt
