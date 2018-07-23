#!/bin/bash

arr=(350seg chr22)

if [ 1 == 2 ]  ###code annotation start
then

for id in `cat 22species.id`
do
    nohup sh blastn.sh $id &
done

fi  ###code annotation start


for tar in ${arr[@]}
do
    for id in `cat 22species.id`
    do
	nohup grep -v "#" alignment/$tar-$id.blastn |awk '{if($8>$7) print $1"\t"$7"\t"$8; else print $1"\t"$8"\t"$7}' |sort -k1,1 -k2n,2 |uniq >bed/$tar-$id.tmp &
	#~/hGT/src/mergeBed.pl bed/$tar-$id.tmp bed/$tar-$id.bed
	#rm bed/$tar-$id.tmp
    done
  
    if [ 1 == 2 ]
    then

	for id in `cat 12nonmammal.id`
	do
            cp bed/$tar-$id.bed bed/nonmammal/
	done
	
	for id in `cat 10mammal.id`
	do
            ~/hGT/src/merge-mammal.pl bed/$tar-$id.bed bed/mammal/$tar-$id-merge.txt
	done

    
	~/hGT/src/merge-nonmammal.pl $tar.fa 500 bed/nonmammal/$tar-merge-cov2-500bp.bed bed/nonmammal/$tar-*bed
	~/hGT/src/screenHGT.pl bed/nonmammal/$tar-merge-cov2-500bp.bed mm-$tar 0.4 bed/mammal/$tar-*merge.txt
	delete "bed/mammal/350seg-", "bed/mammal/chr22-" and "-merge.txt" in the file, then get the real name
	~/hGT/src/getName.pl mm-$tar ~/hGT/data/53genome/info.txt screenHGT-$tar.out

    fi
done

if [ 1 == 2 ]
then

    awk '{if($4<=2) print $1"-"$2"-"$3}' screenHGT-350seg.out |awk -F '-' '{print $1"\t"$2+$4-1"\t"$2+$5-1}' |sort -k1,1 -k2n,2 |uniq >screenHGT-2mammals-350seg.bed
    ~/hGT/src/mergeBed.pl screenHGT-2mammals-350seg.bed screenHGT-2mammals-350seg-merge.bed
    awk '{if($4<=2) print $1"-"$2"-"$3}' screenHGT-chr22.out |awk -F '-' '{print $1"\t"$2"\t"$3}' |sort -k1,1 -k2n,2 >screenHGT-2mammals-chr22.bed

fi

