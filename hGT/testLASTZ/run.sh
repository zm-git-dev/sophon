#!/bin/bash

target=(350seg chr22)

if [ 1 == 2 ] ###code annotation start
then

~/hGT/src/segment.pl chr22.fa 2000 1000 chr22-seg.fa
~/hGT/src/kmer.pl chr22-seg.fa 4 >chr22-seg-4mer.txt
~/hGT/src/compareKmer.pl ~/hGT/kmer/hg19-4mer.txt chr22-seg-4mer.txt distance-4mer.txt
grep -v region distance-4mer.txt |sort -rnk 2 |head -350 |awk '{print $1}' >distance-4mer-pass.info
~/hGT/src/filterFA.pl chr22-seg.fa distance-4mer-pass.info distance-4mer-pass.fa
cp distance-4mer-pass.fa 350seg.fa

for id in `cat 22species.id`
do
    nohup sh lastz.sh $id &
done

for tar in ${target[@]}
do
    for id in `cat 22species.id`
    do
	~/hGT/src/axt2cov.pl cov/$tar-$id.cov axt/$tar-$id.axt #nohup
	awk '{if($9>=0.6) print $1"\t"$2"\t"$3}' cov/$tar-$id.cov |sort -k1,1 -k2n,2 >iden60/$tar-$id.bed #nohup
	~/hGT/src/mergeBed.pl iden60/$tar-$id.bed iden60/$tar-$id-merge.bed
	mv iden60/$tar-$id-merge.bed iden60/$tar-$id.bed
    done

    for id in `cat 12nonmammal.id`
    do
        cp iden60/$tar-$id.bed iden60/nonmammal/
    done

    for id in `cat 10mammal.id`
    do
        ~/hGT/src/merge-mammal.pl iden60/$tar-$id.bed iden60/mammal/$tar-$id-merge.txt
    done
done


for tar in ${target[@]}
do
    ~/hGT/src/merge-nonmammal.pl $tar.fa 500 iden60/nonmammal/$tar-merge-cov2-500bp.bed iden60/nonmammal/$tar-*bed
    ~/hGT/src/screenHGT.pl iden60/nonmammal/$tar-merge-cov2-500bp.bed mm-$tar 0.4 iden60/mammal/$tar-*merge.txt
    #delete "iden60/mammal/350seg-", "iden60/mammal/chr22-" and "-merge.txt" in the file, then get the real name
    ~/hGT/src/getName.pl mm-$tar ~/hGT/data/53genome/info.txt screenHGT-$tar.out
    rm mm-*
done

awk '{if($4<=2) print $1"-"$2"-"$3}' screenHGT-350seg.out |awk -F '-' '{print $1"\t"$2+$4-1"\t"$2+$5-1}' |sort -k1,1 -k2n,2 |uniq >screenHGT-2mammals-350seg.bed
~/hGT/src/mergeBed.pl screenHGT-2mammals-350seg.bed screenHGT-2mammals-350seg-merge.bed
awk '{if($4<=2) print $1"-"$2"-"$3}' screenHGT-chr22.out |awk -F '-' '{print $1"\t"$2"\t"$3}' |sort -k1,1 -k2n,2 >screenHGT-2mammals-chr22.bed

~/hGT/src/getHGTseq.pl ~/hGT/data/hg19/hg19-UCSC-uc.fa screenHGT-2mammals-chr22.bed screenHGT-2mammals-chr22.fa
~/hGT/src/getHGTseq.pl ~/hGT/data/hg19/hg19-UCSC-uc.fa screenHGT-2mammals-350seg-merge.bed screenHGT-2mammals-350seg-merge.fa

~/hGT/src/biodiff.pl ~/hGT/data/hg19/rmsk-merge.bed screenHGT-2mammals-chr22.bed 68hgt2repeat.txt
~/hGT/src/biodiff.pl ~/hGT/data/hg19/rmsk-merge.bed screenHGT-2mammals-350seg-merge.bed 32hgt2repeat.txt


arr=(screenHGT-2mammals-350seg-merge screenHGT-2mammals-chr22)
for id in ${arr[@]}
do
    nohup blastn -task blastn -query $id.fa -db ~/hGT/db/hg19 -out $id-hg19.blastn -evalue 1e-3 -num_threads 16 -outfmt 7 -word_size 9 &
done

mkdir hit-350seg hit-chr22
~/hGT/src/filterHits.pl screenHGT-2mammals-350seg-merge-hg19.blastn hit-350seg
~/hGT/src/filterHits.pl screenHGT-2mammals-chr22-hg19.blastn hit-chr22


mkdir hit-350seg/iden90 hit-chr22/iden90
for tar in ${target[@]}
do
    for i in hit-$tar/*.txt
    do
	echo $i
	pre=${i%.txt}
	suf=${pre#hit-$tar/}
	awk '{if($4>=90) print $0}' $i >hit-$tar/iden90/$suf.txt
	
	cat hit-$tar/iden90/$suf.txt |sort -k1,1 -k2n,2 >mm
	~/hGT/src/mergeBed.pl mm hit-$tar/iden90/$suf.merge.txt
	rm mm
    done
done

fi   ###code annotation end

for id in `grep ">" screenHGT-2mammals-350seg-merge.fa |tr -d ">"`
do
    org_num=$(cat hit-350seg/iden90/$id.txt |wc -l)
    num=$(cat hit-350seg/iden90/$id.merge.txt |wc -l)
    avg_len=$(awk '{print $3-$2+1}' hit-350seg/iden90/$id.merge.txt |awk '{sum+=$1} END {print "",sum/NR}')
    cov_len=$(awk '{print $3-$2+1}' hit-350seg/iden90/$id.merge.txt |awk '{sum+=$1} END {print "",sum}')
    echo -e "$id\t$num\t$avg_len\t$cov_len\t$org_num" >>mm
done

echo -e "id\thit_num\tavg_len\tcov_len" >>summaryHit-iden90-350seg.txt
awk '{if($5==0) print $1"\t0\t0\t0\t0"; else print $1"\t"$2"\t"$3"\t"$4}' mm | sort -rnk 2 >>summaryHit-iden90-350seg.txt
rm mm

for id in `grep ">" screenHGT-2mammals-chr22.fa |tr -d ">"`
do
    org_num=$(cat hit-chr22/iden90/$id.txt |wc -l)
    num=$(cat hit-chr22/iden90/$id.merge.txt |wc -l)
    avg_len=$(awk '{print $3-$2+1}' hit-chr22/iden90/$id.merge.txt |awk '{sum+=$1} END {print "",sum/NR}')
    cov_len=$(awk '{print $3-$2+1}' hit-chr22/iden90/$id.merge.txt |awk '{sum+=$1} END {print "",sum}')
    echo -e "$id\t$num\t$avg_len\t$cov_len\t$org_num" >>mm
done

echo -e "id\thit_num\tavg_len\tcov_len" >>summaryHit-iden90-chr22.txt
awk '{if($5==0) print $1"\t0\t0\t0\t0"; else print $1"\t"$2"\t"$3"\t"$4}' mm | sort -rnk 2 >>summaryHit-iden90-chr22.txt
rm mm
