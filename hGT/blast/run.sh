#!/bin/bash

for obj in `cat non-mammal.id`
do
    echo $obj
    #grep -v "#" seg30M-$obj.blastn |awk '{if($8-$7>=499 ||$8-$7<=-499 ){print $0}}' >non-mammal/$obj-500bp.out
done

for obj in `cat mammal.id`
do
    nohup cat seg30M-$obj* | grep -v "#" |awk '{if($8>$7) print $1"\t"$7"\t"$8; else print $1"\t"$8"\t"$7}' |sort -k1,1 -k2n,2 -k3n,3 |uniq >mammal/$obj-cov.txt &
done

exit
