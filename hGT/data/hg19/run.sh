#!/bin/bash

#grep -v "#" gencode.v19.annotation.gtf |awk '{if($3=="gene") print $1"\t"$4"\t"$5"\t"$10"\t"$14"\t"$18}' |tr -d "\";" >gencode.v19.geneinfo.bed

arr=(antisense lincRNA polymorphic_pseudogene protein_coding pseudogene)
for i in ${arr[@]}
do
    num=$(grep "\s$i\s" gencode.v19.geneinfo.bed |wc -l)
    len=$(grep "\s$i\s" gencode.v19.geneinfo.bed |awk '{print $3-$2+1}' |awk '{sum+=$1} END {print sum}')
    echo -e "$i\t$num\t$len"
done

others_num=$(egrep -v "antisense|lincRNA|polymorphic_pseudogene|protein_coding|pseudogene" gencode.v19.geneinfo.bed |wc -l)
others_len=$(egrep -v "antisense|lincRNA|polymorphic_pseudogene|protein_coding|pseudogene" gencode.v19.geneinfo.bed |awk '{print $3-$2+1}' |awk '{sum+=$1} END {print sum}')
echo -e "others\t$others_num\t$others_len"

