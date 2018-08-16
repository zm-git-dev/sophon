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
done

fi

#mv iden60 iden60-old   ###previous results ==> iden60-old


#################################
#Input: 38M-masked              #
#Ref : 51genomes                #
#choose parameters:             #
#  iden/len/non-mammals/mammals #
#################################

if [ 1 == 2 ]   # code annotation start
then

iden=(40 50 60 70 80 90)
cov=(1 2 3 4 5 6 7 8 9 10 11 12)
len=(100 200 500 800 1000)

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
	    ~/hGT/src/merge-nonmammal.pl 38M-masked.fa $k $j nonmammal/iden$i/merge-cov$j-len$k.txt nonmammal/iden$i/*.bed
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


for i in ${iden[@]}
do
    for j in ${cov[@]}
    do
        for k in ${len[@]}
        do
	    num=$(cat nonmammal/iden$i/merge-cov$j-len$k.txt |wc -l)
	    echo -e "$i\t$j\t$k\t$num" >>number.txt
	done
    done
done

# Non-mammal : iden60, cov1, len200
mkdir nonmammal-iden60-cov1-len200
cp nonmammal/iden60/merge-cov1-len200.txt nonmammal-iden60-cov1-len200/merge.bed
cat nonmammal-iden60-cov1-len200/merge.bed |awk '{print $1"-"$2"-"$3}' |awk -F '-' '{print $1"\t"$2+$4-1"\t"$2+$5-1"\t"$1"-"$2"-"$3"\t"$4"\t"$5}' |sort -k1,1 -k2n,2 >nonmammal-iden60-cov1-len200/merge-trans.bed
~/hGT/src/biodiff.pl ~/hGT/data/hg19/rmsk/Simple_repeat-merge.bed nonmammal-iden60-cov1-len200/merge-trans.bed >nonmammal-iden60-cov1-len200/merge-trans-simple_repeat.txt
## remove regions overlapped with simple_repeat : nonmammal-iden60-cov1-len200/merge-nonSimple.bed, 4,407 segments


fi   # code annotation end

iden=(40 50 60)
len_cuttof=(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1)
count=(0 1 2 3 4 5 6 7 8)

echo -e "iden\tlen_cuttof\tcount\tnum" >>number2.txt
for i in ${iden[@]}
do
    for j in ${len_cuttof[@]}
    do
	~/hGT/src/screenHGT.pl nonmammal-iden60-cov1-len200/merge-nonSimple.bed nonmammal-iden60-cov1-len200/screen-iden$i-len$j.out $j mammal/iden$i/*merge.txt
	for k in ${count[@]}
	do
	    awk '{if($4<='$k') print $1"-"$2"-"$3}' nonmammal-iden60-cov1-len200/screen-iden$i-len$j.out |awk -F '-' '{print $1"\t"$2+$4-1"\t"$2+$5-1}' |sort -k1,1 -k2n,2 |uniq >screen-iden$i-len$j-cov$k.tmp
	    line=$(cat screen-iden$i-len$j-cov$k.tmp |wc -l)
	    if [ $line != 0 ]
	    then
		~/hGT/src/mergeBed.pl screen-iden$i-len$j-cov$k.tmp nonmammal-iden60-cov1-len200/screen-iden$i-len$j-cov$k.bed
		rm screen-iden$i-len$j-cov$k.tmp
	    else
		mv screen-iden$i-len$j-cov$k.tmp nonmammal-iden60-cov1-len200/screen-iden$i-len$j-cov$k.bed
	    fi
	    num=$(cat nonmammal-iden60-cov1-len200/screen-iden$i-len$j-cov$k.bed |wc -l)
	    echo -e "$i\t$j\t$k\t$num" >>number2.txt
	done
    done
done

# Mammal : iden50, len0.6
awk '{if($4<=8) print $0}' nonmammal-iden60-cov1-len200/screen-iden50-len0.6.out >mm
# delete some characters and getName
~/hGT/src/getName.pl mm ~/hGT/data/53genome/info.txt screen-iden50-len0.6-cov8.out
awk '{print $1"-"$2"-"$3}' screen-iden50-len0.6-cov8.out |awk -F '-' '{print $1"\t"$2+$4-1"\t"$2+$5-1}' |sort -k1,1 -k2n,2 |uniq >screen-iden50-len0.6-cov8.bed
~/hGT/src/mergeBed.pl screen-iden50-len0.6-cov8.bed screen-iden50-len0.6-cov8-merge.bed

~/hGT/src/biodiff.pl ~/hGT/data/hg19/rmsk.bed screen-iden50-len0.6-cov8-merge.bed >screen-iden50-len0.6-cov8-merge-rmsk.txt
~/hGT/src/getHGTseq.pl ~/hGT/data/hg19/hg19-UCSC-uc.fa screen-iden50-len0.6-cov8-merge.bed screen-iden50-len0.6-cov8-merge.fa
RepeatMasker screen-iden50-len0.6-cov8-merge.fa
