#!/bin/bash

###############################
# Input : seg38M & 38M-masked #
# Ref : 51genomes             #
# Filter : iden60%,len>=500bp #
#  non-mammals>=2, mammals<=8 # 
###############################

if [ 1 == 2 ]
then

target=(seg38M 38M-masked)
## axt format to bed format (sort and merge)
for tar in ${target[@]}
do
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
    
    ~/hGT/src/merge-nonmammal.pl $tar.fa 500 2 iden60/nonmammal/$tar-merge-cov2-500bp.bed iden60/nonmammal/$tar*bed
    ~/hGT/src/screenHGT.pl iden60/nonmammal/$tar-merge-cov2-500bp.bed mm-$tar 0.4 iden60/mammal/$tar*merge.txt
    ~/hGT/src/getName.pl mm-$tar ~/hGT/data/53genome/info.txt screenHGT-$tar.out
    awk '{if($4<=8) print $1"-"$2"-"$3}' screenHGT-$tar.out |awk -F '-' '{print $1"\t"$2+$4-1"\t"$2+$5-1}' |sort -k1,1 -k2n,2 |uniq >screenHGT-$tar.bed
    ~/hGT/src/mergeBed.pl screenHGT-$tar.bed screenHGT-$tar-merge.bed
    ~/hGT/src/getHGTseq.pl ~/hGT/data/hg19/hg19-UCSC-uc.fa screenHGT-$tar-merge.bed screenHGT-$tar-merge.fa
    RepeatMasker screenHGT-$tar-merge.fa

    ~/hGT/src/getName.pl mm-$tar ~/hGT/data/53genome/info.txt screenHGT-$tar.out
    awk '{if($4<=8) print $1"-"$2"-"$3}' screenHGT-$tar.out |awk -F '-' '{print $1"\t"$2+$4-1"\t"$2+$5-1}' |sort -k1,1 -k2n,2 |uniq >screenHGT-$tar.bed
    ~/hGT/src/mergeBed.pl screenHGT-$tar.bed screenHGT-$tar-merge.bed
    ~/hGT/src/getHGTseq.pl ~/hGT/data/hg19/hg19-UCSC-uc.fa screenHGT-$tar-merge.bed screenHGT-$tar-merge.fa
    RepeatMasker screenHGT-$tar-merge.fa
done

fi

#mv iden60 iden60-old   ###previous results ==> iden60-old


#################################
#Input: 38M-masked              #
#Ref : 51genomes                #
#choose parameters:             #
#  iden/len/non-mammals/mammals #
#################################

iden=(40 50 60 70 80 90)

if [ 1 == 2 ]   # code annotation start
then

for i in ${iden[@]}
do
    mkdir iden$i
    for id in `cat 51species.id`
    do
        awk '{if($9*100>='$i') print $1"\t"$2"\t"$3}' cov/38M-masked-$id.cov |sort -k1,1 -k2n,2 >iden$i/$id.tmp

	num=$(cat iden$i/$id.tmp |wc -l)
	if [ $num != 0 ]
	then
	    ~/hGT/src/mergeBed.pl iden$i/$id.tmp iden$i/$id.bed
	    rm iden$i/$id.tmp
	else
	    mv iden$i/$id.tmp iden$i/$id.bed
	fi
    done
done

find iden*0 |grep tmp |xargs rm  # delete *.tmp

mkdir mammal nonmammal


cov=(2 3 4 5 6 7 8 9 10 11 12)
len=(100 200 500 800 1000)

for i in ${iden[@]}
do
    mkdir nonmammal/iden$i
    for id in `cat 12nonmammal.id`
    do
	cp iden$i/$id.bed nonmammal/iden$i
    done
    
    for j in ${cov[@]}
    do
	for k in ${len[@]}
	do	    
	    ~/hGT/src/merge-nonmammal.pl 38M-masked.fa $k $j nonmammal/iden$i/merge-cov$j-len$k.bed nonmammal/iden$i/*.bed
	done
    done
done


for i in ${iden[@]}
do
    mkdir mammal/iden$i

    for id in `cat 39mammal.id`
    do
        nohup ~/hGT/src/merge-mammal.pl iden$i/$id.bed mammal/iden$i/$id-merge.txt &
    done
done

fi   # code annotation end

