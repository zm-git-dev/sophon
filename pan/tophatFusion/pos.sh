#!/bin/bash

for LINE in `cat 17fusion.out |awk '{print $1}'`
do
    gene1=$(echo $LINE |awk -F '|' '{print $1}')
    gene2=$(echo $LINE |awk -F '|' '{print $2}')
    #echo -e "$gene1\t$gene2"
    grep $gene1 summaryHTML-3.out |grep $gene2
done
