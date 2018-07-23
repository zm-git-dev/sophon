#!/bin/bash

#arr=(iden60len40 iden40len20 gb2015-136gene)

arr=(iden60len40 iden40len20 seg30M)
for target in ${arr[@]}
do
    ./../screen-hgt.pl nonmammal-$target/region-nonmammal.out screenHGT-$target-0.4.out 0.4 mammal-$target/*merged.txt
    awk '{if($4<=8){print $0}}' screenHGT-$target-0.4.out |awk -F '[\t|-]' '{print $1"\t"$2+$4"\t"$3+$5}' >screenHGT-$target-0.4-8mammals.info
done
