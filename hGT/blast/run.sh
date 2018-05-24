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

~/hGT/src/screenHGT.pl mergeBed/nonmammal/merge-cov2-500bp.bed screenHGT-len0.4.out 0.4 mergeBed/mammal/*merged.txt
./getName.pl screenHGT-len0.4.out ~/hGT/data/53genome/info.txt mm
mv mm screenHGT-len0.4.out
### replace: CHR -> chr; chrUN -> chrUn; GL -> gl

awk '{if($4<=8){print $0}}' screenHGT-len0.4.out |awk -F '[\t|-]' '{print $1"\t"$2+$4-1"\t"$2+$5-1"\t"$6"\t"$7}' |sort -k1,1 -k2n,2 >screenHGT-len0.4-8mammals.bed
~/hGT/src/getHGTseq.pl ~/hGT/data/hg19/hg19-UCSC.fa screenHGT-len0.4-8mammals.bed screenHGT-len0.4-8mammals.fa
blastn -task blastn -query screenHGT-len0.4-8mammals.fa -db ~/hGT/db/hg19 -out screenHGT-len0.4-8mammals-hg19.blastn -evalue 1e-3 -num_threads 20 -outfmt 7 -word_size 9

### split the hits according to the query sequence, to different files
./filterHits.pl screenHGT-len0.4-8mammals-hg19.blastn

for i in hit/*.txt
do
    pre=${i%.txt}
    cat $i |sort -k1,1 -k2n,2 >$pre.sort.txt
    ~/hGT/compare2lastz/mergeBed.pl $pre.sort.txt $pre.merge.txt
    rm $pre.sort.txt
done

fi    ###code annotation end

for id in `grep ">" screenHGT-len0.4-8mammals.fa |tr -d ">"`
do
    num=$(cat hit/$id.txt |wc -l)
    avg_len=$(awk '{print $3-$2+1}' hit/$id.txt |awk '{sum+=$1} END {print "",sum/NR}')
    avg_iden=$(awk '{print $4}' hit/$id.txt |awk '{sum+=$1} END {print "",sum/NR}')
    merge_num=$(cat hit/$id.merge.txt |wc -l)
    cov_len=$(awk '{print $3-$2+1}' hit/$id.merge.txt |awk '{sum+=$1} END {print "",sum}')
    echo -e "$id\t$num\t$avg_len\t$avg_iden\t$merge_num\t$cov_len" mm
done

#header: id hit_num avg_len avg_identity merge_hit_num cov_len
cat mm |grep -v awk |awk '{if($2!=0) print $0}' >summaryHits.txt

# multi-alignment
muscle -in screenHGT-len0.4-8mammals.fa -out screenHGT-len0.4-8mammals.fa.mucle
# build the phylogenetic tree
FastTreeMP -nt screenHGT-len0.4-8mammals.fa.mucle >screenHGT-len0.4-8mammals.fa.mucle.tree

