#!/bin/bash

#target=(seg38M 38M-masked)
target=(38M-masked)

if [ 1 == 2 ]  ###code annotation start
then

## axt format to bed format (sort and merge)
for tar in ${target[@]}
do
    for id in `cat 51species.id`
    do
	#nohup ~/hGT/src/axt2cov.pl cov/$tar-$id.cov axt/$tar-$id.axt &
	#nohup awk '{if($9>=0.6) print $1"\t"$2"\t"$3}' cov/$tar-$id.cov |sort -k1,1 -k2n,2 >iden60/$tar-$id.bed &
	#nohup ~/hGT/src/mergeBed.pl iden60/$tar-$id.bed iden60/$tar-$id-merge.bed &
	#mv iden60/$tar-$id-merge.bed iden60/$tar-$id.bed
    done    
    
    for id in `cat 12nonmammal.id`
    do
	cp iden60/$tar-$id.bed iden60/nonmammal
    done

    for id in `cat 39mammal.id`
    do
        nohup ~/hGT/src/merge-mammal.pl iden60/$tar-$id.bed iden60/mammal/$tar-$id-merge.txt &
    done

done

fi  ###code annotation end


#~/hGT/src/merge-nonmammal.pl seg38M-masked.fa 500 iden60/nonmammal/38M-masked-merge-cov2-500bp.bed iden60/nonmammal/38M-masked*bed
#~/hGT/src/screenHGT.pl iden60/nonmammal/38M-masked-merge-cov2-500bp.bed mm 0.4 iden60/mammal/38M-masked*merge.txt
#~/hGT/src/getName.pl mm ~/hGT/data/53genome/info.txt screenHGT-38M-masked.out
#awk '{if($4<=8) print $1"-"$2"-"$3}' screenHGT-38M-masked.out |awk -F '-' '{print $1"\t"$2+$4-1"\t"$2+$5-1}' |sort -k1,1 -k2n,2 |uniq >screenHGT-8mammals-38M-masked.bed
#~/hGT/src/mergeBed.pl screenHGT-8mammals-38M-masked.bed screenHGT-8mammals-38M-masked-merge.bed
