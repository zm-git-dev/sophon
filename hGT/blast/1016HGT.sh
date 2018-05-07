#!/bin/bash

for obj in `cat non-mammal.id`
do
    echo $obj
    #grep -v "#" 1016HGT-$obj.blastn |awk '{if($8-$7>=499 ||$8-$7<=-499 ){print $0}}' >HGT-nonmammal/$obj-500bp.out
done

#arr=(GCF_000004665.1_Callithrix_jacchus-3.2_genomic GCF_000151905.2_gorGor4_genomic GCF_000772875.2_Mmul_8.0.1_genomic GCF_002880775.1_Susie_PABv2_genomic)

#for obj in ${arr[@]}
for obj in `cat mammal.id`
do
    nohup cat 1016HGT-$obj.blastn |grep -v "#" |awk '{if($8>$7) print $1"\t"$7"\t"$8; else print $1"\t"$8"\t"$7}' |sort -k1,1 -k2n,2 |uniq >HGT-mammal/$obj-cov.txt &
done
