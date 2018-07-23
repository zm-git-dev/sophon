#!/bin/bash

#target=(seg38M 38M-masked)
#target=(38M-masked)
target=(seg38M)


## axt format to bed format (sort and merge)
for tar in ${target[@]}
do
    if [ 1 == 2 ]
    then
	for id in `cat 51species.id`
	do
	    nohup ~/hGT/src/axt2cov.pl cov/$tar-$id.cov axt/$tar-$id.axt &
	    nohup awk '{if($9>=0.6) print $1"\t"$2"\t"$3}' cov/$tar-$id.cov |sort -k1,1 -k2n,2 >$tar-$id.tmp &
	    nohup ~/hGT/src/mergeBed.pl $tar-$id.tmp iden60/$tar-$id.bed &
	    rm $tar-$id.tmp
	done    
	
	for id in `cat 12nonmammal.id`
	do
	    cp iden60/$tar-$id.bed iden60/nonmammal
	done
	
	for id in `cat 39mammal.id`
	do
            nohup ~/hGT/src/merge-mammal.pl iden60/$tar-$id.bed iden60/mammal/$tar-$id-merge.txt &
	done
	
	~/hGT/src/merge-nonmammal.pl $tar.fa 500 iden60/nonmammal/$tar-merge-cov2-500bp.bed iden60/nonmammal/$tar*bed
	~/hGT/src/screenHGT.pl iden60/nonmammal/$tar-merge-cov2-500bp.bed mm-$tar 0.4 iden60/mammal/$tar*merge.txt
	~/hGT/src/getName.pl mm-$tar ~/hGT/data/53genome/info.txt screenHGT-$tar.out
	awk '{if($4<=8) print $1"-"$2"-"$3}' screenHGT-$tar.out |awk -F '-' '{print $1"\t"$2+$4-1"\t"$2+$5-1}' |sort -k1,1 -k2n,2 |uniq >screenHGT-8mammals-$tar.bed
	~/hGT/src/mergeBed.pl screenHGT-8mammals-$tar.bed screenHGT-8mammals-$tar-merge.bed
	~/hGT/src/getHGTseq.pl ~/hGT/data/hg19/hg19-UCSC-uc.fa screenHGT-8mammals-$tar-merge.bed screenHGT-8mammals-$tar-merge.fa
	RepeatMasker screenHGT-8mammals-$tar-merge.fa
    fi
    
    ~/hGT/src/getName.pl mm-$tar ~/hGT/data/53genome/info.txt screenHGT-$tar.out
    awk '{if($4<=8) print $1"-"$2"-"$3}' screenHGT-$tar.out |awk -F '-' '{print $1"\t"$2+$4-1"\t"$2+$5-1}' |sort -k1,1 -k2n,2 |uniq >screenHGT-8mammals-$tar.bed
    ~/hGT/src/mergeBed.pl screenHGT-8mammals-$tar.bed screenHGT-8mammals-$tar-merge.bed
    ~/hGT/src/getHGTseq.pl ~/hGT/data/hg19/hg19-UCSC-uc.fa screenHGT-8mammals-$tar-merge.bed screenHGT-8mammals-$tar-merge.fa
    RepeatMasker screenHGT-8mammals-$tar-merge.fa
    
done
