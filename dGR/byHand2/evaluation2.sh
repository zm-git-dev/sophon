#!/usr/bin/bash

if [ 1 == 2 ]
then
 
all=$(grep ">" dataSet/merged.dgr_cdhit0.95.fa |wc -l)

for ((i=1; i<=10; i ++))
do
    cd ~/dGR/byHand2/group_$i
    ./../metacsstMain -build arg.config -in ~/dGR/byHand2/dataSet/merged.dgr_cdhit0.95.fa -out mm -thread 32
    right=$(grep "DGR" mm/out.gtf |wc -l)
    partial=`echo "scale=4; $right / $all" | bc`
    
    ./../reBuildDGR_pthread.pl mm/out.gtf ~/dGR/byHand2/dataSet/merged.dgr_cdhit0.95.fa 1.txt 2.txt 0.5 3 30 32
    right=$(grep "DGR" 1.txt |wc -l)
    intact=`echo "scale=4; $right / $all" | bc`
    
    rm -rf mm 1.txt 2.txt 
    echo -e "group_$i\t$partial\t$intact"
done

fi

all=$(grep ">" ~/dGR/data/hv29.fa |wc -l)

for ((i=1; i<=10; i ++))
do
    cd ~/dGR/byHand2/group_$i
    ./../metacsstMain -build arg.config -in ~/dGR/data/hv29.fa -out mm -thread 20
    right=$(grep "DGR" mm/out.gtf |wc -l)
    partial=`echo "scale=4; $right / $all" | bc`

    ./../reBuildDGR_pthread.pl mm/out.gtf ~/dGR/data/hv29.fa 1.txt 2.txt 0.5 3 30 10
    right=$(grep "DGR" 1.txt |wc -l)
    intact=`echo "scale=4; $right / $all" | bc`

    rm -rf mm 1.txt 2.txt
    echo -e "group_$i\t$partial\t$intact"
done


exit
