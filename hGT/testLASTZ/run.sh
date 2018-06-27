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

    for i in `cat 12nonmammal.id`
    do
        cp iden60/$tar-$i.bed iden60/nonmammal/
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
     delete "iden60/mammal/350seg-", "iden60/mammal/chr22-" and "-merge.txt" in the file, then get the real name
    #~/hGT/src/getName.pl mm-$tar ~/hGT/data/53genome/info.txt screenHGT-$tar.out
    rm mm-*
done

fi   ###code annotation end

awk '{if($4<=2) print $1"-"$2"-"$3}' screenHGT-350seg.out |awk -F '-' '{print $1"\t"$2+$4-1"\t"$2+$5-1}' |sort -k1,1 -k2n,2 |uniq >screenHGT-2mammals-350seg.bed
~/hGT/src/mergeBed.pl screenHGT-2mammals-350seg.bed screenHGT-2mammals-350seg-merge.bed

awk '{if($4<=2) print $1"-"$2"-"$3}' screenHGT-chr22.out |awk -F '-' '{print $1"\t"$2"\t"$3}' |sort -k1,1 -k2n,2 >screenHGT-2mammals-chr22.bed

