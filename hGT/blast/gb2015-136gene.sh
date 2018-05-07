#!/bin/bash

for obj in `cat non-mammal.id`
do
    echo $obj
    grep -v "#" gb2015-136gene-$obj.blastn |awk '{if($8-$7>=499 ||$8-$7<=-499 ){print $0}}' >gb2015-136gene-nonmammal/$obj-500bp.out
done

for obj in `cat mammal.id`
do
    nohup cat gb2015-136gene-$obj.* |grep -v "#" |awk '{if($8>$7) print $1"\t"$7"\t"$8; else print $1"\t"$8"\t"$7}' |sort -k1,1 -k2n,2 |uniq >gb2015-136gene-mammal/$obj-cov.txt &
done
