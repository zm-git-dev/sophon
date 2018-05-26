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


~/hGT/src/merge-nonmammal.pl ~/hGT/segment/hg19-seg1k-step1k-4mer-pass.fa 500 iden60/nonmammal/merge-cov2-500bp.bed iden60/nonmammal/*bed

~/hGT/src/screenHGT.pl iden60/nonmammal/merge-cov2-500bp.bed screenHGT.out 0.4 iden60/mammal/*merge.txt
# delete "iden60/mammal/" and "_genomic-merge.txt" in the file, then get the real name
./../blast/getName.pl screenHGT.out ~/hGT/data/53genome/info.txt mm
mv mm screenHGT.out

## filter : <= 8 mammals
## replace: CHR -> chr; UN -> Un; GL -> gl; COX_HAP2 -> cox_hap2
awk '{if($4<=8) print $1"-"$2"-"$3}' screenHGT.out |awk -F '-' '{print $1"\t"$2+$4-1"\t"$2+$5-1}' |sort -k1,1 -k2n,2 >screenHGT-8mammals.bed
## merge the HGTs if overlap
~/hGT/src/mergeBed.pl screenHGT-8mammals.bed screenHGT-8mammals-merge.bed

## overlap info with gene annotation
~/hGT/src/biodiff.pl ~/hGT/data/hg19/gencode.v19.geneinfo.bed screenHGT-8mammals-merge.bed 378hgt2gene.txt
## overlap info with repeats
~/hGT/src/biodiff.pl ~/hGT/data/hg19/rmsk-merge.bed screenHGT-8mammals-merge.bed 378hgt2repeat.txt

## get HGT sequences
~/hGT/src/getHGTseq.pl ~/hGT/data/hg19/hg19-UCSC.fa screenHGT-8mammals-merge.bed screenHGT-8mammals-merge.fa
## run blastn to hg19 reference genome
blastn -task blastn -query screenHGT-8mammals-merge.fa -db ~/hGT/db/hg19 -out screenHGT-8mammals-merge-hg19.blastn -evalue 1e-3 -num_threads 32 -outfmt 7 -word_size 9

./../blast/filterHits.pl screenHGT-8mammals-merge-hg19.blastn 


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

for id in `grep ">" screenHGT-8mammals-merge.fa |tr -d ">"`
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
