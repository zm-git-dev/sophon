#!/bin/bash

for obj in `cat nonmammal.id`
do
    grep -v "#" iden60len40-$obj.blastn |awk '{if($8-$7>=499 ||$8-$7<=-499 ){print $0}}' >nonmammal-iden60len40/$obj-500bp.out
done

for obj in `cat mammal.id`
do
    nohup cat iden60len40-$obj.* |grep -v "#" |awk '{if($8>$7) print $1"\t"$7"\t"$8; else print $1"\t"$8"\t"$7}' |sort -k1,1 -k2n,2 |uniq >mammal-iden60len40/$obj-cov.txt &
done
